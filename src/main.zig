const std = @import("std");
const cli = @import("zig-cli");
const knownFolders = @import("known-folders");
const tomlz = @import("tomlz");

var config = struct {
    system_only: bool = false,
    home_only: bool = false,
    nix_on_droid: bool = false,
    update: bool = false,
    collect_garbage: ?u32 = null,
    flake_path: ?[]const u8 = null,
    hostname: ?[]const u8 = null,
    root_command: ?[]const u8 = null,
    inputs: []const []const u8 = undefined,
}{};

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
var arena = std.heap.ArenaAllocator.init(gpa.allocator());
const allocator = arena.allocator();

// common functions
fn spawn(command: []const []const u8) !void {
    var cmd = std.process.Child.init(command, allocator);
    try cmd.spawn();
    _ = try cmd.wait();
}

pub fn getFlakePath(no_hostname: bool) ![]const u8 {
    const c = &config;
    const home: ?[]const u8 = try knownFolders.getPath(allocator, knownFolders.KnownFolder.home);

    if (c.hostname == null or no_hostname) {
        const path: []const u8 = try std.fmt.allocPrint(allocator, "{s}/{s}", .{ home.?, config.flake_path.? });
        return path;
    } else {
        const path: []const u8 = try std.fmt.allocPrint(allocator, "{s}/{s}#{s}", .{ home.?, config.flake_path.?, config.hostname.? });
        return path;
    }
}

// nixos functions
fn sync_nixos() !void {
    const path = try getFlakePath(false);
    try std.io.getStdOut().writer().print("syncing nix config at {s}\n\n", .{path});

    const command = &[_][]const u8{ config.root_command orelse "sudo", "nixos-rebuild", "switch", "--flake", path };
    try spawn(command);
}

fn sync_home() !void {
    const path = try getFlakePath(false);
    try std.io.getStdOut().writer().print("syncing home-manager at {s}\n\n", .{path});

    const home = &[_][]const u8{ "home-manager", "-b", "hbk", "switch", "--flake", path };
    try spawn(home);
}

// nix on droid
fn sync_nixondroid() !void {
    const stdout = std.io.getStdOut().writer();

    const c = &config;
    if (c.flake_path == null) {
        try stdout.print("syncing config: nix-on-droid switch\n\n", .{});

        const command = &[_][]const u8{ "nix-on-droid", "switch" };
        try spawn(command);
    } else {
        const path = try getFlakePath(false);
        try stdout.print("syncing nix system config at {s}\n\n", .{path});

        const command = &[_][]const u8{ "nix-on-droid", "switch", "--flake", path };
        try spawn(command);
    }
}

// update flake inputs
fn update() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("updating flake inputs\n\n", .{});

    const path = try getFlakePath(true);
    if (config.inputs.len == @as(usize, 0)) {
        const command = &[_][]const u8{ "nix", "flake", "update", "--flake", path };
        try spawn(command);
    } else {
        var command = std.ArrayList([]const u8).init(allocator);
        defer command.deinit();
        try command.appendSlice(&[_][]const u8{ "nix", "flake", "update", "--flake", path });
        try command.appendSlice(config.inputs);
        try spawn(command.items);
    }
}

// cleaning functions
fn garbage() !void {
    const stdout = std.io.getStdOut().writer();
    const c = &config;

    const value: u32 = c.collect_garbage orelse 30;

    try stdout.print("deleting garbage older than {} days", .{value});

    var peroid = std.ArrayList(u8).init(allocator);
    defer peroid.deinit();
    _ = try peroid.writer().print("{}d", .{value});

    var command = std.ArrayList([]const u8).init(allocator);
    defer command.deinit();
    try command.appendSlice(&[_][]const u8{ "nix-collect-garbage", "--delete-older-than" });
    try command.append(peroid.items);
    try spawn(command.items);
}

// wraper
fn sync() !void {
    const stdout = std.io.getStdOut().writer();

    const c = &config;

    if (c.update) {
        try update();
    }

    if (c.collect_garbage != null) {
        try garbage();
    }

    if (c.nix_on_droid) {
        try sync_nixondroid();
    } else {
        if (c.flake_path == null) {
            try stdout.print("syncing nixos", .{});

            const command = &[_][]const u8{ config.root_command orelse "sudo", "nixos-rebuild", "switch" };
            try spawn(command);
        } else {
            if (c.system_only) {
                try sync_nixos();
            } else if (c.home_only) {
                try sync_home();
            } else {
                try sync_nixos();
                try sync_home();
            }
        }
    }
}

// cli
fn parser() cli.AppRunner.Error!cli.ExecFn {
    var r = try cli.AppRunner.init(allocator);

    const arg_parser = cli.App{
        .command = cli.Command{
            .name = "zix",
            .description = cli.Description{
                .one_line = "helper program for nix and home-manager",
            },
            .target = cli.CommandTarget{
                .subcommands = &.{
                    cli.Command{
                        .name = "sync",
                        .description = cli.Description{
                            .one_line = "sync configuration and system",
                            .detailed = "sync nixos and/or home-manager configuration",
                        },
                        .options = &.{
                            .{
                                .long_name = "hostname",
                                .short_alias = 'n',
                                .help = "hostname defined in configuration",
                                .value_ref = r.mkRef(&config.hostname),
                            },
                            .{
                                .long_name = "root-command",
                                .short_alias = 'r',
                                .help = "command to get root priviliges eg. sudo or doas",
                                .value_ref = r.mkRef(&config.root_command),
                            },
                            .{
                                .long_name = "flake",
                                .short_alias = 'f',
                                .help = "path to where flake is stored relative to home folder",
                                .value_ref = r.mkRef(&config.flake_path),
                            },
                            .{
                                .long_name = "system-only",
                                .short_alias = 'S',
                                .help = "only sync system configuration",
                                .value_ref = r.mkRef(&config.system_only),
                            },
                            .{
                                .long_name = "home-manager",
                                .short_alias = 'H',
                                .help = "only sync home manager configuration",
                                .value_ref = r.mkRef(&config.home_only),
                            },
                            .{
                                .long_name = "update",
                                .short_alias = 'u',
                                .help = "update flake inputs before sync",
                                .value_ref = r.mkRef(&config.update),
                            },
                            .{
                                .long_name = "garbage",
                                .short_alias = 'g',
                                .help = "collect garbage older than X days",
                                .value_ref = r.mkRef(&config.collect_garbage),
                            },
                        },
                        .target = cli.CommandTarget{
                            .action = cli.CommandAction{
                                .exec = sync,
                            },
                        },
                    },
                    cli.Command{
                        .name = "update",
                        .description = cli.Description{
                            .one_line = "update flake inputs",
                            .detailed = "update flake inputs",
                        },
                        .target = cli.CommandTarget{
                            .action = cli.CommandAction{
                                .positional_args = cli.PositionalArgs{
                                    .optional = try r.mkSlice(cli.PositionalArg, &.{
                                        .{
                                            .name = "inputs",
                                            .help = "inputs to update",
                                            .value_ref = r.mkRef(&config.inputs),
                                        },
                                    }),
                                },
                                .exec = update,
                            },
                        },
                    },
                    cli.Command{
                        .name = "garbage",
                        .description = cli.Description{
                            .one_line = "collect garbage older than x days",
                            .detailed = "runs nix collcect garbage",
                        },
                        .target = cli.CommandTarget{
                            .action = cli.CommandAction{
                                .positional_args = cli.PositionalArgs{
                                    .required = try r.mkSlice(cli.PositionalArg, &.{
                                        .{
                                            .name = "period",
                                            .help = "delete older than period in days",
                                            .value_ref = r.mkRef(&config.collect_garbage),
                                        },
                                    }),
                                },
                                .exec = garbage,
                            },
                        },
                    },
                },
            },
        },
        .version = "0.3.3",
        .author = "Strix Vyxlor",
    };

    return r.getAction(&arg_parser);
}

// config loading
fn load_config() !void {
    const c = &config;
    var conf_dir = try knownFolders.open(allocator, knownFolders.KnownFolder.local_configuration, .{});
    defer conf_dir.?.close();

    if (conf_dir) |dir| {
        const conf_file = dir.openFile("zix/conf.toml", .{}) catch |err| {
            switch (err) {
                std.fs.File.OpenError.FileNotFound => {
                    std.debug.print("found no config", .{});
                    return;
                },
                else => return err,
            }
        };
        defer conf_file.close();

        const stat = try conf_file.stat();
        const buffer = try conf_file.readToEndAlloc(allocator, stat.size);
        defer allocator.free(buffer);

        var table = try tomlz.parse(allocator, buffer);
        c.nix_on_droid = table.getBool("nix_on_droid") orelse false;
        c.flake_path = table.getString("flake_path") orelse null;
        c.hostname = table.getString("hostname") orelse null;
        c.root_command = table.getString("root_command") orelse null;
    }
}

pub fn main() !void {
    try load_config();
    defer arena.deinit();

    const action = try parser();
    return action();
}

