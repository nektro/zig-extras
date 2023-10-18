const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    _ = b.addModule(
        "extras",
        .{ .source_file = .{ .path = "src/lib.zig" } },
    );
}
