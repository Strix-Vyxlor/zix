const std = @import("std");
const cli = @import("zig-cli");
const knownFolders = @import("known-folders");

var config = struct {
    system_only: bool = false,
    home_only: bool = false,
    nix_on_droid: bool = false,
    flake_path: ?[]const u8 = null,
    hostname: ?[]const u8 = null,
    root_command: ?[]const u8 = null,
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

pub fn getFlakePath() ![]const u8 {
    const c = &config;
    const home: ?[]const u8 = try knownFolders.getPath(allocator, knownFolders.KnownFolder.home);

    if (c.hostname == null) {
        const path: []const u8 = try std.fmt.allocPrint(allocator, "{s}/{s}", .{ home.?, config.flake_path.? });
        return path;
    } else {
        const path: []const u8 = try std.fmt.allocPrint(allocator, "{s}/{s}#{s}", .{ home.?, config.flake_path.?, config.hostname.? });
        return path;
    }
}

fn sync_nixos() !void {
    const path = try getFlakePath();
    try std.io.getStdOut().writer().print("syncing nix config at {s}\n\n", .{path});

    const command = &[_][]const u8{ config.root_command orelse "sudo", "nixos-rebuild", "switch", "--flake", path };
    try spawn(command);
}

fn sync_home() !void {
    const path = try getFlakePath();
    try std.io.getStdOut().writer().print("syncing home-manager at {s}\n\n", .{path});

    const home = &[_][]const u8{ "home-manager", "-b", "hbk", "switch", "--flake", path };
    try spawn(home);
}

fn sync() !void {
    const stdout = std.io.getStdOut().writer();

    const c = &config;
    if (c.nix_on_droid) {
        if (c.flake_path == null) {
            try stdout.print("syncing config: nix-on-droid switch\n\n", .{});

            const command = &[_][]const u8{ "nix-on-droid", "switch" };
            try spawn(command);
        } else {
            const path = try getFlakePath();
            try stdout.print("syncing nix system config at {s}\n\n", .{path});

            const command = &[_][]const u8{ "nix-on-droid", "switch", "--flake", path };
            try spawn(command);
        }
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
                        },
                        .target = cli.CommandTarget{
                            .action = cli.CommandAction{
                                .exec = sync,
                            },
                        },
                    },
                },
            },
        },
        .version = "0.3.0",
        .author = "Strix Vyxlor",
    };

    return r.getAction(&arg_parser);
}

pub fn main() !void {
    const action = try parser();
    return action();
}
