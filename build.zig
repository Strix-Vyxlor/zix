const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const zig_cli = b.dependency("zig-cli", .{ .target = target, .optimize = optimize });
    const known_folders = b.dependency("known-folders", .{});
    const tomlz = b.dependency("tomlz", .{
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{
        .name = "zix",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe.root_module.addImport("zig-cli", zig_cli.module("zig-cli"));
    exe.root_module.addImport("known-folders", known_folders.module("known-folders"));
    exe.root_module.addImport("tomlz", tomlz.module("tomlz"));

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
