const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib_mod = b.addModule("zpng", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const lib = b.addLibrary(.{
        .name = "zpng",
        .root_module = lib_mod,
    });

    b.installArtifact(lib);

    const lib_test_run = b.addTest(.{
        .name = "zpng",
        .root_module = lib_mod,
    });

    const test_step = b.step("test", "Test the app");
    test_step.dependOn(&lib_test_run.step);

    const lib_check = b.addLibrary(.{
        .name = "zpng",
        .root_module = lib_mod,
    });

    const check_step = b.step("check", "Test the app");
    check_step.dependOn(&lib_check.step);
}
