const std = @import("std");
const cli = @import("zig-cli");
const common = @import("common.zig");
const knownFolders = @import("known-folders");

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
    if (config.use_flake == true or !std.mem.eql(u8, config.flake_path, ".nix-config")) {
        const home: ?[]const u8 = try knownFolders.getPath(allocator.*, knownFolders.KnownFolder.home);
        const path: []const u8 = try std.fmt.allocPrint(allocator.*, "{s}/{s}", .{ home.?, config.flake_path });

        std.log.debug("syncing nix system config at {s}, update: {}", .{ path, config.update_flake });
    } else {
        std.debug.print("syncing nix-on-droid: nix-on-droid switch", .{});
        const command = &[_][]const u8{ "nix-on-droid", "switch" };
        try common.spawn(command, allocator);
    }
}
