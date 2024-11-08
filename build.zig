const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Steps
    const install_step = b.getInstallStep();
    const run_step = b.step("run", "Run the app");
    const test_step = b.step("test", "Run unit tests");

    // Dependencies
    const raylib_dep = b.dependency("raylib-zig", .{});

    const exe = b.addExecutable(.{
        .name = "qdraw",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    linkRaylib(raylib_dep, exe);

    const install_cmd = b.addInstallArtifact(exe, .{});
    install_step.dependOn(&install_cmd.step);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(install_step);

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    run_step.dependOn(&run_cmd.step);

    const exe_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    linkRaylib(raylib_dep, exe_tests);

    const run_tests = b.addRunArtifact(exe_tests);
    test_step.dependOn(&run_tests.step);
}

pub fn linkRaylib(dep: *std.Build.Dependency, exe: *std.Build.Step.Compile) void {
    exe.linkLibC();
    exe.linkLibrary(dep.artifact("raylib"));
    exe.root_module.addImport("raylib", dep.module("raylib"));
}
