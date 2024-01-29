const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");
const rawInt = extras.rawInt;

pub fn rawIntBytes(comptime T: type, comptime literal: comptime_int) [@bitSizeOf(T) / 8]u8 {
    return comptime std.mem.toBytes(rawInt(T, literal))[0 .. @bitSizeOf(T) / 8].*;
}

test {
    try std.testing.expect(std.mem.eql(
        u8,
        &rawIntBytes(u128, 0x5d41402abc4b2a76b9719d911017c592),
        &[_]u8{ 0x5d, 0x41, 0x40, 0x2a, 0xbc, 0x4b, 0x2a, 0x76, 0xb9, 0x71, 0x9d, 0x91, 0x10, 0x17, 0xc5, 0x92 },
    ));
}

test {
    try std.testing.expect(std.mem.eql(
        u8,
        &rawIntBytes(u160, 0xaaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d),
        &[_]u8{ 0xaa, 0xf4, 0xc6, 0x1d, 0xdc, 0xc5, 0xe8, 0xa2, 0xda, 0xbe, 0xde, 0x0f, 0x3b, 0x48, 0x2c, 0xd9, 0xae, 0xa9, 0x43, 0x4d },
    ));
}
