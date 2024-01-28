const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");
const readType = extras.readType;
const rawInt = extras.rawInt;

pub fn indexBufferT(bytes: [*]const u8, comptime T: type, endian: std.builtin.Endian, idx: usize, max_len: usize) T {
    std.debug.assert(idx < max_len);
    var fbs = std.io.fixedBufferStream((bytes + (idx * @sizeOf(T)))[0..@sizeOf(T)]);
    return readType(fbs.reader(), T, endian) catch |err| switch (err) {
        error.EndOfStream => unreachable, // assert above has been violated
    };
}

test {
    const bytes = std.mem.toBytes(rawInt(u32, 0x4e5a7da9));
    try std.testing.expect(indexBufferT(&bytes, u16, .Big, 0, 2) == 0x4e5a);
    try std.testing.expect(indexBufferT(&bytes, u16, .Big, 1, 2) == 0x7da9);
}
test {
    const bytes = std.mem.toBytes(rawInt(u32, 0x4e5a7da9));
    try std.testing.expect(indexBufferT(&bytes, u16, .Little, 0, 2) == 0x5a4e);
    try std.testing.expect(indexBufferT(&bytes, u16, .Little, 1, 2) == 0xa97d);
}
