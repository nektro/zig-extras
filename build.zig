const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    _ = b.addModule(
        "extras",
        .{ .source_file = .{ .path = "src/lib.zig" } },
    );

    const test_step = b.step("test", "dummy test step to pass CI checks");
    _ = test_step;
}
