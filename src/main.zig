const std = @import("std");
const cli = @import("zig-cli");

var config = struct {
    system_only: bool = false,
    home_only: bool = false,
    nix_on_droid: bool = true,
    flake_path: []const u8 = "",
    hostname: []const u8 = "",
    root_command: []const u8 = "",
}{};

fn sync() !void {
    std.debug.print("zix is work", .{});
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    const allocator = arena.allocator();

    defer arena.deinit();
    defer {
        _ = gpa.deinit();
    }

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
    };

    return r.run(&arg_parser);
}
