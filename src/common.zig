const std = @import("std");
const cli = @import("zig-cli");
const knownFolders = @import("known-folders");

const Config = @import("config.zig");
var allocator: *std.mem.Allocator = undefined;
var config: *Config = undefined;

pub fn init(conf: *Config, alloc: *std.mem.Allocator) void {
    config = conf;
    allocator = alloc;
}

pub fn updateGitCommand() cli.Command {
    return cli.Command{ .name = "update-git", .target = cli.CommandTarget{ .action = cli.CommandAction{
        .exec = updateGit,
    } } };
}

pub fn updateCommand() cli.Command {
    return cli.Command{ .name = "update", .target = cli.CommandTarget{ .action = cli.CommandAction{
        .exec = update,
    } } };
}

pub fn getFlakePath() ![]const u8 {
    const home: ?[]const u8 = try knownFolders.getPath(allocator.*, knownFolders.KnownFolder.home);
    const path: []const u8 = try std.fmt.allocPrint(allocator.*, "{s}/{s}", .{ home.?, config.flake_path });

    if (std.mem.eql(u8, config.hostname, "none")) {
        return path;
    } else {
        const path_with_hostname: []const u8 = try std.fmt.allocPrint(allocator.*, "{s}#{s}", .{ path, config.hostname });
        return path_with_hostname;
    }
}

pub fn updateGit() anyerror!void {
    std.log.debug("updating config", .{});
}

pub fn update() anyerror!void {
    const path = try getFlakePath();
    const command = &[_][]const u8{ "nix", "flake", "update", path };
    try spawn(command);
}

pub fn spawn(command: []const []const u8) !void {
    var cmd = std.process.Child.init(command, allocator.*);
    try cmd.spawn();
    _ = try cmd.wait();
}
