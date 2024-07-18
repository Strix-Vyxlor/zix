const std = @import("std");
const cli = @import("zig-cli");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

var config = struct {
    system: bool = false,
    home: bool = false,
    update_flake: bool = false,
    flake_path: []const u8 = undefined,
}{};

fn nix_on_droid_command() !cli.Command {
    const sync_command = cli.Command{
        .name = "sync",
        .target = cli.CommandTarget{
            .action = cli.CommandAction{
                .exec = nix_on_droid_sync,
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

fn parseArgs() cli.AppRunner.Error!cli.ExecFn {
    var r = try cli.AppRunner.init(std.heap.page_allocator);

    const sync_command = cli.Command{
        .name = "sync",
        .options = &.{},
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

    const app = cli.App{
        .command = cli.Command{
            .name = "zix",
            .description = cli.Description{
                .one_line = "Tool for updating nix config",
            },
            .options = &.{ .{
                .long_name = "flake",
                .help = "use flake",
                .short_alias = 'f',
                .value_ref = r.mkRef(&config.flake_path),
                .value_name = "PATH",
            }, .{
                .long_name = "system",
                .help = "only update system config",
                .short_alias = 'S',
                .value_ref = r.mkRef(&config.system),
            }, .{
                .long_name = "home",
                .help = "only update home-manager config",
                .short_alias = 'H',
                .value_ref = r.mkRef(&config.home),
            }, .{
                .long_name = "update",
                .help = "pull latest version of flake path git",
                .short_alias = 'u',
                .value_ref = r.mkRef(&config.update_flake),
            } },
            .target = cli.CommandTarget{
                .subcommands = &.{ try nix_on_droid_command(), sync_command, update_command },
            },
        },
        .version = "0.1",
        .author = "Strix Vyxlor",
    };

    return r.getAction(&app);
}

pub fn main() anyerror!void {
    const action = try parseArgs();
    return action();
}

fn sync() !void {
    const c = &config;
    if (c.flake_path.len != 0) {
        if (c.system == c.home) {
            std.log.debug("syncing nix config flake at {s}, update: {}", .{ c.flake_path, c.update_flake });
        } else if (c.home) {
            std.log.debug("syncing home-manager at {s}, update: {}", .{ c.flake_path, c.update_flake });
        } else {
            std.log.debug("syncing nix system config at {s}, update: {}", .{ c.flake_path, c.update_flake });
        }
    } else std.log.debug("syncing nix on droid", .{});
}

fn nix_on_droid_sync() !void {
    const c = &config;
    if (c.flake_path.len != 0) {
        std.log.debug("syncing nix on droid config flake at {s}, update: {}", .{ c.flake_path, c.update_flake });
    } else std.log.debug("syncing nix on droid config", .{});
}

fn update() !void {
    const c = &config;
    std.log.debug("updating config at {s}", .{c.flake_path});
}
