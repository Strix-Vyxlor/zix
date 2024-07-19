const std = @import("std");
const cli = @import("zig-cli");
const nix_on_droid = @import("nix-on-droid.zig");
const nix = @import("nix.zig");
const common = @import("common.zig");

const Config = @import("config.zig");
var config: *Config = undefined;

pub fn init(conf: *Config) void {
    config = conf;
}

pub fn parseArgs(allocator: *std.mem.Allocator) cli.AppRunner.Error!cli.ExecFn {
    var r = try cli.AppRunner.init(allocator.*);

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
                .subcommands = &.{ try nix_on_droid.nixOnDroidCommand(), nix.syncCommand(), common.updateCommand() },
            },
        },
        .version = "0.1",
        .author = "Strix Vyxlor",
    };

    return r.getAction(&app);
}
