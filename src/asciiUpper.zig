const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn asciiUpper(alloc: std.mem.Allocator, input: string) ![]u8 {
    var buf = try alloc.dupe(u8, input);
    for (0..buf.len) |i| {
        buf[i] = std.ascii.toUpper(buf[i]);
    }
    return buf;
}
