const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

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

        pub fn at(self: *const Self, idx: usize) T {
            return extras.indexBufferT(self.bytes, T, endian, idx, self.max_len);
        }
    };
}
