const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const zig_cli = b.dependency("cli", .{ .target = target, .optimize = optimize });
    const known_folders = b.dependency("known_folders", .{ .target = target, .optimize = optimize });
    const tomlz = b.dependency("tomlz", .{
        .target = target,
        .optimize = optimize,
    });

    const exe_mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("src/main.zig"),
    });

    exe_mod.addImport("zig-cli", zig_cli.module("zig-cli"));
    exe_mod.addImport("known-folders", known_folders.module("known-folders"));
    exe_mod.addImport("tomlz", tomlz.module("tomlz"));

    const exe = b.addExecutable(.{
        .name = "zix",
        .root_module = exe_mod,
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
