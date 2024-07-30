const std = @import("std");
const cli = @import("zig-cli");
const common = @import("common.zig");

const Config = @import("config.zig");
var config: *Config = undefined;
var allocator: *std.mem.Allocator = undefined;

pub fn init(conf: *Config, alloc: *std.mem.Allocator) void {
    config = conf;
    allocator = alloc;
}

pub fn nixOnDroidCommand() !cli.Command {
    const sync_command = cli.Command{
        .name = "sync",
        .target = cli.CommandTarget{
            .action = cli.CommandAction{
                .exec = sync,
            },
        },
    };

    return cli.Command{ .name = "nix-on-droid", .description = cli.Description{
        .one_line = "nix-on-droid updating and syncing",
    }, .target = cli.CommandTarget{
        .subcommands = &.{sync_command},
    } };
}

pub fn sync() anyerror!void {
    const stdout = std.io.getStdOut().writer();

    if (config.use_flake == true or !std.mem.eql(u8, config.flake_path, ".nix-config")) {
        const path = try common.getFlakePath();
        try stdout.print("syncing nix system config at {s}", .{path});

        const command = &[_][]const u8{ "nix-on-droid", "switch", "--flake", path };
        try common.spawn(command);
    } else {
        try stdout.print("syncing config: nix-on-droid switch", .{});

        const command = &[_][]const u8{ "nix-on-droid", "switch" };
        try common.spawn(command);
    }
}
