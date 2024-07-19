const std = @import("std");
const parser = @import("parser.zig");
const nix_on_droid = @import("nix-on-droid.zig");
const nix = @import("nix.zig");
const json = @import("zig-json");
const knownFolders = @import("known-folders");

const common = @import("common.zig");

const Config = @import("config.zig");
var config: Config = .{
    .system = false,
    .home = false,
    .update_flake = false,
    .use_flake = false,
    .flake_path = undefined,
};

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
var arena = std.heap.ArenaAllocator.init(gpa.allocator());
var allocator = arena.allocator();

fn loadConfig() !void {
    var conf_dir = try knownFolders.open(allocator, knownFolders.KnownFolder.local_configuration, .{});
    defer conf_dir.?.close();
    if (conf_dir) |dir| {
        const conf_file = dir.openFile("zix/zix.conf", .{}) catch |err| {
            switch (err) {
                std.fs.File.OpenError.FileNotFound => {
                    config.flake_path = ".nix-config";
                    std.log.debug("useing default path", .{});
                    return;
                },
                else => return err,
            }
        };

        const value = try json.parseFile(conf_file, allocator);
        errdefer value.deinit(allocator);
        defer value.deinit(allocator);

        const path = value.get("path").string();
        config.flake_path = try allocator.dupe(u8, path);
        std.debug.print("using {s}\n", .{path});

        config.use_flake = value.get("flake").boolean();
        config.update_flake = value.get("update").boolean();
    }
}

pub fn main() anyerror!void {
    try loadConfig();

    nix_on_droid.init(&config);
    nix.init(&config);
    parser.init(&config);

    try common.spawn(&[_][]const u8{"sleep", "4"}, &allocator);
    std.log.debug("hello", .{});

    const action = try parser.parseArgs(&allocator);

    return action();
}
