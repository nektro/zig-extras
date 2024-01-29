const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

const alphabet = "0123456789abcdefghijklmnopqrstuvwxyz";

pub fn randomSlice(alloc: std.mem.Allocator, rand: std.rand.Random, comptime T: type, len: usize) ![]T {
    var buf = try alloc.alloc(T, len);
    var i: usize = 0;
    while (i < len) : (i += 1) {
        buf[i] = alphabet[rand.int(u8) % alphabet.len];
    }
    return buf;
}

test {
    const allocator = std.testing.allocator;
    const rand = std.crypto.random;
    const slice = try randomSlice(allocator, rand, u8, 10);
    defer allocator.free(slice);
    try std.testing.expect(slice.len == 10);
}
