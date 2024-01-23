const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn RingBuffer(comptime T: type, comptime capacity: usize) type {
    return struct {
        items: [capacity]T = undefined,
        len: usize = 0,
        comptime capacity: usize = capacity,

        const Self = @This();

        pub fn append(self: *Self, new_item: T) void {
            if (self.len == self.capacity) {
                for (1..self.len) |i| self.items[i - 1] = self.items[i];
                self.len -= 1;
            }
            self.items[self.len] = new_item;
            self.len += 1;
        }
    };
}
