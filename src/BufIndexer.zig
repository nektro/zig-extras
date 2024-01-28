const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");
const indexBufferT = extras.indexBufferT;
const rawInt = extras.rawInt;

pub fn BufIndexer(comptime T: type, comptime endian: std.builtin.Endian) type {
    return struct {
        bytes: [*]const u8,
        max_len: usize,

        const Self = @This();

        pub fn init(bytes: [*]const u8, max_len: usize) Self {
            return .{
                .bytes = bytes,
                .max_len = max_len,
            };
        }

        /// asserts 'idx' to be in bounds
        pub fn at(self: *const Self, idx: usize) T {
            return indexBufferT(self.bytes, T, endian, idx, self.max_len);
        }
    };
}

test {
    const bytes = std.mem.toBytes(rawInt(u64, 0x4e5a7da9f3f1d132));
    const bindex = BufIndexer(u64, .Big).init(&bytes, 1);
    try std.testing.expect(bindex.at(0) == 0x4e5a7da9f3f1d132);
}

test {
    const bytes = std.mem.toBytes(rawInt(u64, 0x4e5a7da9f3f1d132));
    const bindex = BufIndexer(u32, .Big).init(&bytes, 2);
    try std.testing.expect(bindex.at(0) == 0x4e5a7da9);
    try std.testing.expect(bindex.at(1) == 0xf3f1d132);
}

test {
    const bytes = std.mem.toBytes(rawInt(u64, 0x4e5a7da9f3f1d132));
    const bindex = BufIndexer(u16, .Big).init(&bytes, 4);
    try std.testing.expect(bindex.at(0) == 0x4e5a);
    try std.testing.expect(bindex.at(1) == 0x7da9);
    try std.testing.expect(bindex.at(2) == 0xf3f1);
    try std.testing.expect(bindex.at(3) == 0xd132);
}

test {
    const bytes = std.mem.toBytes(rawInt(u64, 0x4e5a7da9f3f1d132));
    const bindex = BufIndexer(u8, .Big).init(&bytes, 8);
    try std.testing.expect(bindex.at(0) == 0x4e);
    try std.testing.expect(bindex.at(1) == 0x5a);
    try std.testing.expect(bindex.at(2) == 0x7d);
    try std.testing.expect(bindex.at(3) == 0xa9);
    try std.testing.expect(bindex.at(4) == 0xf3);
    try std.testing.expect(bindex.at(5) == 0xf1);
    try std.testing.expect(bindex.at(6) == 0xd1);
    try std.testing.expect(bindex.at(7) == 0x32);
}
