const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.option(std.builtin.Mode, "mode", "") orelse .Debug;
    const disable_llvm = b.option(bool, "disable_llvm", "use the non-llvm zig codegen") orelse false;

    _ = b.addModule(
        "extras",
        .{ .root_source_file = b.path("src/lib.zig") },
    );

    const tests = b.addTest(.{
        .root_source_file = b.path("src/lib.zig"),
        .target = target,
        .optimize = mode,
    });
    tests.use_llvm = !disable_llvm;
    tests.use_lld = !disable_llvm;

    const run_tests = b.addRunArtifact(tests);
    run_tests.has_side_effects = true;

    const test_step = b.step("test", "dummy test step to pass CI checks");
    test_step.dependOn(&run_tests.step);
}
