const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn asciiUpper(alloc: std.mem.Allocator, input: string) ![:0]u8 {
    var buf = try alloc.dupeZ(u8, input);
    for (0..buf.len) |i| {
        buf[i] = std.ascii.toUpper(buf[i]);
    }
    return buf;
}

test {
    const allocator = std.testing.allocator;
    const input = "hello";
    const upper = try asciiUpper(allocator, input);
    defer allocator.free(upper);
    try std.testing.expect(std.mem.eql(u8, upper, "HELLO"));
}

test {
    const allocator = std.testing.allocator;
    const input = "bUtTer?!";
    const upper = try asciiUpper(allocator, input);
    defer allocator.free(upper);
    try std.testing.expect(std.mem.eql(u8, upper, "BUTTER?!"));
}
