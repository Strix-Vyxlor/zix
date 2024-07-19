const std = @import("std");
const cli = @import("zig-cli");

const Config = @import("config.zig");
var c: *Config = undefined;

pub fn init(conf: *Config) void {
    c = conf;
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
    if (c.use_flake == true or !std.mem.eql(u8, c.flake_path, ".nix-config")) {
        std.log.debug("syncing nix system config at {s}, update: {}", .{ c.flake_path, c.update_flake });
    } else std.log.debug("syncing nix", .{});
}
