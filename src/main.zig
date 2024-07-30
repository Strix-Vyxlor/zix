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
    .use_flake = false,
    .flake_path = undefined,
    .nix_on_droid = false,
    .hostname = undefined,
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
                    std.log.debug("useing default config", .{});
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
        std.log.debug("using flake ~/{s}\n", .{path});

        config.use_flake = value.get("flake").boolean();
        config.nix_on_droid = value.get("nix-on-droid").boolean();

        const hostname = value.get("hostname").string();
        config.hostname = try allocator.dupe(u8, hostname);
    }
}

pub fn main() anyerror!void {
    try loadConfig();

    common.init(&config, &allocator);
    nix_on_droid.init(&config, &allocator);
    nix.init(&config, &allocator);
    parser.init(&config);

    const action = try parser.parseArgs(&allocator);
    return action();
}
