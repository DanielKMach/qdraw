const std = @import("std");
const rlz = @import("raylib-zig");

const config = struct {
    const emcc_path = "C:\\Tools\\emsdk\\upstream\\emscripten";
    const shell_file = "shell.html";
};

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Steps
    const install_step = b.getInstallStep();
    const run_step = b.step("run", "Run the app");
    const test_step = b.step("test", "Run unit tests");

    if (target.query.os_tag == .emscripten and config.emcc_path.len > 0) {
        b.sysroot = config.emcc_path;
    }

    // Dependencies
    const raylib_dep = b.dependency("raylib-zig", .{
        .target = target,
        .optimize = optimize,
    });

    if (target.query.os_tag == .emscripten) {
        const proj_lib = rlz.emcc.compileForEmscripten(b, "qdraw", "src/main.zig", target, optimize);

        linkRaylib(raylib_dep, proj_lib);

        const link_emcc = try rlz.emcc.linkWithEmscripten(b, &.{ proj_lib, raylib_dep.artifact("raylib") });
        if (config.shell_file.len > 0) {
            link_emcc.addArgs(&.{ "--shell-file", config.shell_file });
        }
        if (b.args) |args| {
            link_emcc.addArgs(args);
        }

        install_step.dependOn(&link_emcc.step);
        const run_emcc = try rlz.emcc.emscriptenRunStep(b);
        run_emcc.step.dependOn(&link_emcc.step);
        run_step.dependOn(&run_emcc.step);
        return;
    }

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
