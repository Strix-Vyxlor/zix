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

    if (std.mem.eql(u8, config.hostname, "none")) {
        const path: []const u8 = try std.fmt.allocPrint(allocator.*, "{s}/{s}", .{ home.?, config.flake_path });
        return path;
    } else {
        const path: []const u8 = try std.fmt.allocPrint(allocator.*, "{s}/{s}#{s}", .{ home.?, config.flake_path, config.hostname });
        return path;
    }
}

pub fn updateGit() anyerror!void {
    const path = try getFlakePath();

    const command = &[_][]const u8{ "bash", try std.fmt.allocPrint(allocator.*, "{s}/pull.sh", .{path}) };
    try spawn(command);
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
