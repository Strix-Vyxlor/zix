const std = @import("std");
const cli = @import("zig-cli");

pub fn updateCommand() cli.Command {
    return cli.Command{
        .name = "update",
        .target = cli.CommandTarget{
            .action = cli.CommandAction{
                .exec = update,
            }
        }
    };
}

pub fn update() anyerror!void {
    std.log.debug("updating config", .{});
}