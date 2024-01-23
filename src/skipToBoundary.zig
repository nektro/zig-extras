const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn skipToBoundary(pos: u64, boundary: u64, reader: anytype) !void {
    // const gdiff = counter.bytes_read % 4;
    // for (range(if (gdiff > 0) 4 - gdiff else 0)) |_| {
    const a = pos;
    const b = boundary;
    try reader.skipBytes(((a + (b - 1)) & ~(b - 1)) - a, .{});
}
