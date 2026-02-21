const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");
const parseDigits = extras.parseDigits;

pub fn from_hex(array: anytype) [array.len / 2]u8 {
    var result: [array.len / 2]u8 = undefined;
    for (0..array.len / 2) |i| result[i] = parseDigits(u8, array[i * 2 ..][0..2], 16) catch unreachable;
    return result;
}

test {
    try std.testing.expectEqualSlices(
        u8,
        &.{ 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x30 },
        &from_hex("3132333435363738393031323334353637383930"),
    );
}
