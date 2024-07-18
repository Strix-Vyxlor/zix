const std = @import("std");
const cli = @import("zig-cli");

const Config = @import("config.zig");
var c: *Config = undefined;

pub fn init(conf: *Config) void {
    c = conf;
}

pub fn sync() anyerror!void {
    if (c.use_flake == true or !std.mem.eql(u8, c.flake_path, "~/.nix-config")) {
        if (c.system == c.home) {
            std.log.debug("syncing nix config flake at {s}, update: {}", .{ c.flake_path, c.update_flake });
        } else if (c.home) {
            std.log.debug("syncing home-manager at {s}, update: {}", .{ c.flake_path, c.update_flake });
        } else {
            std.log.debug("syncing nix system config at {s}, update: {}", .{ c.flake_path, c.update_flake });
        }
    } else std.log.debug("syncing nix", .{});
}

pub fn update() anyerror!void {
    std.log.debug("updating config at {s}", .{c.flake_path});
}
