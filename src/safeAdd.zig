const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

/// Allows u32 + i16 to work
pub fn safeAdd(a: anytype, b: anytype) @TypeOf(a) {
    if (b >= 0) {
        return a + @as(@TypeOf(a), @intCast(b));
    }
    return a - @as(@TypeOf(a), @intCast(-@as(extras.OneBiggerInt(@TypeOf(b)), b)));
}
