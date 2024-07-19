const std = @import("std");
const cli = @import("zig-cli");

pub fn updateCommand() cli.Command {
    return cli.Command{ .name = "update", .target = cli.CommandTarget{ .action = cli.CommandAction{
        .exec = update,
    } } };
}

pub fn update() anyerror!void {
    std.log.debug("updating config", .{});
}

pub fn spawn(command: []const []const u8, allocator: *std.mem.Allocator) !void {
    var cmd = std.process.Child.init(command, allocator.*);
    try cmd.spawn();
    _ = try cmd.wait();
    
}
