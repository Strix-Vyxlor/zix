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

pub fn syncCommand() cli.Command {
    return cli.Command{ .name = "sync", .target = cli.CommandTarget{ .action = cli.CommandAction{
        .exec = sync,
    } } };
}

pub fn upgradeCommand() cli.Command {
    return cli.Command{ .name = "upgrade", .target = cli.CommandTarget{ .action = cli.CommandAction{
        .exec = upgrade,
    } } };
}

pub fn upgrade() anyerror!void {
    try common.update();
    try sync();
}

fn sync() anyerror!void {
    if (config.use_flake == true or !std.mem.eql(u8, config.flake_path, ".nix-config")) {
        if (config.system == config.home) {
            const path = try common.getFlakePath();
            std.debug.print("syncing nix config flake at {s}", .{path});

            const command = &[_][]const u8{ "nixos-rebuild", "switch", "--flake", path };
            try common.spawn(command);

            const home = &[_][]const u8{ "home-manager", "switch", "--flake", path };
            try common.spawn(home);
        } else if (config.home) {
            const path = try common.getFlakePath();
            std.debug.print("syncing home-manager at {s}", .{path});

            const home = &[_][]const u8{ "home-manager", "switch", "--flake", path };
            try common.spawn(home);
        } else {
            const path = try common.getFlakePath();
            std.debug.print("syncing nix system config at {s}", .{path});

            const command = &[_][]const u8{ "nixos-rebuild", "switch", "--flake", path };
            try common.spawn(command);
        }
    } else {
        std.debug.print("syncing nix", .{});

        const command = &[_][]const u8{ "nixos-rebuild", "switch" };
        try common.spawn(command);
    }
}
