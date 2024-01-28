const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");
const builtin = @import("builtin");
const native_endian = builtin.target.cpu.arch.endian();

pub fn rawInt(comptime T: type, comptime literal: comptime_int) T {
    comptime std.debug.assert(@typeInfo(T).Int.bits % 8 == 0);
    return switch (native_endian) {
        .Little => @byteSwap(@as(T, literal)),
        .Big => @compileError("unreachable"),
    };
}

test {
    const bytes = std.mem.toBytes(rawInt(u16, 0x4e5a));
    try std.testing.expect(bytes[0] == 0x4e);
}
test {
    const bytes = std.mem.toBytes(rawInt(u16, 0x4e5a));
    try std.testing.expect(bytes[0] == 0x4e);
    try std.testing.expect(bytes[1] == 0x5a);
}
test {
    const bytes = std.mem.toBytes(rawInt(u32, 0x4e5a7da9));
    try std.testing.expect(bytes[0] == 0x4e);
    try std.testing.expect(bytes[1] == 0x5a);
    try std.testing.expect(bytes[2] == 0x7d);
    try std.testing.expect(bytes[3] == 0xa9);
}
test {
    const bytes = std.mem.toBytes(rawInt(u64, 0x4e5a7da9f3f1d132));
    try std.testing.expect(bytes[0] == 0x4e);
    try std.testing.expect(bytes[1] == 0x5a);
    try std.testing.expect(bytes[2] == 0x7d);
    try std.testing.expect(bytes[3] == 0xa9);
    try std.testing.expect(bytes[4] == 0xf3);
    try std.testing.expect(bytes[5] == 0xf1);
    try std.testing.expect(bytes[6] == 0xd1);
    try std.testing.expect(bytes[7] == 0x32);
}
