const std = @import("std");
const cli = @import("zig-cli");

const Config = @import("config.zig");
var config: *Config = undefined;

pub fn init(conf: *Config) void {
    config = conf;
}

pub fn syncCommand() cli.Command {
    return cli.Command{ .name = "sync", .target = cli.CommandTarget{ .action = cli.CommandAction{
        .exec = sync,
    } } };
}

fn sync() anyerror!void {
    if (config.use_flake == true or !std.mem.eql(u8, config.flake_path, ".nix-config")) {
        if (config.system == config.home) {
            std.log.debug("syncing nix config flake at {s}, update: {}", .{ config.flake_path, config.update_flake });
        } else if (config.home) {
            std.log.debug("syncing home-manager at {s}, update: {}", .{ config.flake_path, config.update_flake });
        } else {
            std.log.debug("syncing nix system config at {s}, update: {}", .{ config.flake_path, config.update_flake });
        }
    } else std.log.debug("syncing nix", .{});
}
