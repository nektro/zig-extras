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

test {
    try std.testing.expect(try sliceToInt(u32, u4, &.{ 0x4, 0xe, 0x5, 0xa, 0x7, 0xd, 0xa, 0x9 }) == 0x4e5a7da9);
}
test {
    try std.testing.expect(try sliceToInt(u30, u3, &.{ 0b010, 0b011, 0b100, 0b101, 0b101, 0b001, 0b111, 0b101, 0b101, 0b010 }) == 0b010011100101101001111101101010);
}
test {
    try std.testing.expect(try sliceToInt(u30, u5, &.{ 0b01001, 0b11001, 0b01101, 0b00111, 0b11011, 0b01010 }) == 0b010011100101101001111101101010);
}
