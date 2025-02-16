const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.option(std.builtin.Mode, "mode", "") orelse .Debug;
    const disable_llvm = b.option(bool, "disable_llvm", "use the non-llvm zig codegen") orelse false;

    const mod = b.addModule("extras", .{
        .root_source_file = b.path("src/lib.zig"),
    });

    const tests = b.addTest(.{
        .root_source_file = b.path("test.zig"),
        .target = target,
        .optimize = mode,
    });
    tests.root_module.addImport("extras", mod);
    tests.use_llvm = !disable_llvm;
    tests.use_lld = !disable_llvm;

    const test_step = b.step("test", "Run all library tests");
    const tests_run = b.addRunArtifact(tests);
    tests_run.has_side_effects = true;
    test_step.dependOn(&tests_run.step);
}
