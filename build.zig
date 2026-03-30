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

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .optimize = optimize,
        .target = target,
        .imports = &.{
            .{ .name = "zpng", .module = lib_mod },
        },
    });

    const exe = b.addExecutable(.{
        .name = "png",
        .root_module = exe_mod,
    });

    b.installArtifact(exe);

    const exe_run = b.addRunArtifact(exe);
    exe_run.step.dependOn(b.getInstallStep());

    exe_run.addFileArg(b.path("input.png"));
    if (b.args) |args| {
        exe_run.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&exe_run.step);

    const exe_test_run = b.addTest(.{
        .name = "zpng",
        .root_module = exe_mod,
    });

    const lib_test_run = b.addTest(.{
        .name = "zpng",
        .root_module = lib_mod,
    });

    const test_step = b.step("test", "Test the app");
    test_step.dependOn(&lib_test_run.step);
    test_step.dependOn(&exe_test_run.step);

    const lib_check = b.addLibrary(.{
        .name = "zpng",
        .root_module = lib_mod,
    });

    const exe_check = b.addExecutable(.{
        .name = "zpng",
        .root_module = exe_mod,
    });

    const check_step = b.step("check", "Test the app");
    check_step.dependOn(&lib_check.step);
    check_step.dependOn(&exe_check.step);
}
