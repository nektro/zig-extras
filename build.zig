const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    b.addModule(.{
        .name = "extras",
        .source_file = .{ .path = "src/lib.zig" },
    });
}
