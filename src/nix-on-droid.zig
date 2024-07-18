const std = @import("std");
const cli = @import("zig-cli");

const Config = @import("config.zig");
var c: *Config = undefined;

pub fn init(conf: *Config) void {
    c = conf;
}

pub fn nixOnDroidCommand(update: fn () anyerror!void) !cli.Command {
    const sync_command = cli.Command{
        .name = "sync",
        .target = cli.CommandTarget{
            .action = cli.CommandAction{
                .exec = sync,
            },
        },
    };

    const update_command = cli.Command{
        .name = "update",
        .target = cli.CommandTarget{
            .action = cli.CommandAction{
                .exec = update,
            },
        },
    };

    return cli.Command{ .name = "nix-on-droid", .description = cli.Description{
        .one_line = "nix-on-droid updating and syncing",
    }, .target = cli.CommandTarget{
        .subcommands = &.{ sync_command, update_command },
    } };
}

fn sync() anyerror!void {
    if (c.flake_path.len != 0) {
        std.log.debug("syncing nix on droid config flake at {s}, update: {}", .{ c.flake_path, c.update_flake });
    } else std.log.debug("syncing nix on droid config", .{});
}
