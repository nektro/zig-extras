const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");
const assert = std.debug.assert;

pub fn FixedMaxBuffer(comptime max_len: usize) type {
    return struct {
        buf: [max_len]u8,
        len: usize,
        pos: usize,

        const Self = @This();
        pub const Reader = std.io.Reader(*Self, error{}, read);

        pub fn init(r: anytype, runtime_len: usize) !Self {
            var fmr = Self{
                .buf = undefined,
                .len = runtime_len,
                .pos = 0,
            };
            _ = try r.readAll(fmr.buf[0..runtime_len]);
            return fmr;
        }

        pub fn reader(self: *Self) Reader {
            return .{ .context = self };
        }

        fn read(self: *Self, dest: []u8) error{}!usize {
            const buf = self.buf[0..self.len];
            const size = @min(dest.len, buf.len - self.pos);
            const end = self.pos + size;
            std.mem.copy(u8, dest[0..size], buf[self.pos..end]);
            self.pos = end;
            return size;
        }

        pub fn readLen(self: *Self, len: usize) []const u8 {
            assert(self.pos + len <= self.len);
            defer self.pos += len;
            return self.buf[self.pos..][0..len];
        }

        pub fn atEnd(self: *const Self) bool {
            return self.pos == self.len;
        }
    };
}

test {
    std.testing.refAllDecls(FixedMaxBuffer(16));
}
