const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");
const OneBiggerInt = extras.OneBiggerInt;

/// Allows u32 +% i16 to work
pub fn safeAddWrap(a: anytype, b: anytype) @TypeOf(a) {
    if (b >= 0) {
        return a +% @as(@TypeOf(a), @intCast(b));
    }
    return a -% @as(@TypeOf(a), @intCast(-@as(OneBiggerInt(@TypeOf(b)), b)));
}

test {
    try std.testing.expect(safeAddWrap(@as(u16, 0), @as(i8, -2)) == 65534);
}
test {
    try std.testing.expect(safeAddWrap(@as(u16, 10), @as(i8, -2)) == 8);
}
test {
    try std.testing.expect(safeAddWrap(@as(u16, 65535), @as(i8, 1)) == 0);
}
test {
    try std.testing.expect(safeAddWrap(@as(u16, 256), @as(i8, -128)) == 128);
}
