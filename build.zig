const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.option(std.builtin.Mode, "mode", "") orelse .Debug;

    _ = b.addModule(
        "extras",
        .{ .source_file = .{ .path = "src/lib.zig" } },
    );

    const exe_unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/lib.zig" },
        .target = target,
        .optimize = mode,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const test_step = b.step("test", "dummy test step to pass CI checks");
    test_step.dependOn(&run_exe_unit_tests.step);
}
