const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn RingBuffer(comptime T: type, comptime capacity: usize) type {
    return struct {
        items: [capacity]T,
        len: usize,
        comptime capacity: usize = capacity,

        const Self = @This();

        pub const empty: Self = .{
            .items = undefined,
            .len = 0,
        };

        pub fn append(self: *Self, new_item: T) void {
            if (self.len == self.capacity) {
                for (1..self.len) |i| self.items[i - 1] = self.items[i];
                self.len -= 1;
            }
            self.items[self.len] = new_item;
            self.len += 1;
        }

        pub fn slice(self: *Self) []T {
            return self.items[0..self.len];
        }

        pub fn rest(self: *Self) []T {
            return self.items[self.len..];
        }
    };
}

test {
    std.testing.refAllDecls(RingBuffer(u8, 16));
}
