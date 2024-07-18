const std = @import("std");
const cli = @import("zig-cli");
const nix_on_droid = @import("nix-on-droid.zig");
const nix = @import("nix.zig");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const Config = @import("config.zig");
var config: Config = .{
    .system = false,
    .home = false,
    .update_flake = false,
    .use_flake = false,
    .flake_path = "~/.nix-config",
};

fn parseArgs() cli.AppRunner.Error!cli.ExecFn {
    var r = try cli.AppRunner.init(std.heap.page_allocator);

    const sync_command = cli.Command{
        .name = "sync",
        .options = &.{},
        .target = cli.CommandTarget{
            .action = cli.CommandAction{
                .exec = nix.sync,
            },
        },
    };

    const update_command = cli.Command{
        .name = "update",

        .target = cli.CommandTarget{
            .action = cli.CommandAction{
                .exec = nix.update,
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
                .help = "use default flake",
                .short_alias = 'f',
                .value_ref = r.mkRef(&config.use_flake),
            }, .{
                .long_name = "flake-override",
                .help = "use flake at custom directory",
                .short_alias = 'F',
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
                .subcommands = &.{ try nix_on_droid.nix_on_droid_command(nix.update), sync_command, update_command },
            },
        },
        .version = "0.1",
        .author = "Strix Vyxlor",
    };

    return r.getAction(&app);
}

pub fn main() anyerror!void {
    nix_on_droid.init(&config);
    nix.init(&config);

    const action = try parseArgs();
    return action();
}
