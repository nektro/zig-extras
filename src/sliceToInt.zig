const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn sliceToInt(comptime T: type, comptime E: type, slice: []const E) !T {
    const a = @typeInfo(T).Int.bits;
    const b = @typeInfo(E).Int.bits;
    if (a < b * slice.len) return error.Overflow;

    var n: T = 0;
    for (slice, 0..) |item, i| {
        const shift: std.math.Log2Int(T) = @intCast(b * (slice.len - 1 - i));
        n = n | (@as(T, item) << shift);
    }
    return n;
}
