const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn asciiLower(alloc: std.mem.Allocator, input: string) ![:0]u8 {
    var buf = try alloc.dupeZ(u8, input);
    for (input, 0..) |c, i| buf[i] = std.ascii.toLower(c);
    return buf;
}

pub fn asciiLowerComptime(comptime input: string) [:0]u8 {
    var buf: [input.len + 1]u8 = undefined;
    for (input, 0..) |c, i| buf[i] = std.ascii.toLower(c);
    buf[input.len] = 0;
    const result = buf[0..input.len :0];
    return result;
}
