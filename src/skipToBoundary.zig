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

test {
    const array = [_]u8{ 5, 4, 3, 2, 1, 0 };
    var fba = std.io.fixedBufferStream(&array);
    var counter = std.io.countingReader(fba.reader());
    const reader = counter.reader();
    try reader.skipBytes(0, .{});
    try skipToBoundary(counter.bytes_read, 4, reader);
    try std.testing.expect(counter.bytes_read == 0);
}

test {
    const array = [_]u8{ 5, 4, 3, 2, 1, 0 };
    var fba = std.io.fixedBufferStream(&array);
    var counter = std.io.countingReader(fba.reader());
    const reader = counter.reader();
    try reader.skipBytes(1, .{});
    try skipToBoundary(counter.bytes_read, 4, reader);
    try std.testing.expect(counter.bytes_read == 4);
}

test {
    const array = [_]u8{ 5, 4, 3, 2, 1, 0 };
    var fba = std.io.fixedBufferStream(&array);
    var counter = std.io.countingReader(fba.reader());
    const reader = counter.reader();
    try reader.skipBytes(2, .{});
    try skipToBoundary(counter.bytes_read, 4, reader);
    try std.testing.expect(counter.bytes_read == 4);
}

test {
    const array = [_]u8{ 5, 4, 3, 2, 1, 0 };
    var fba = std.io.fixedBufferStream(&array);
    var counter = std.io.countingReader(fba.reader());
    const reader = counter.reader();
    try reader.skipBytes(3, .{});
    try skipToBoundary(counter.bytes_read, 4, reader);
    try std.testing.expect(counter.bytes_read == 4);
}

test {
    const array = [_]u8{ 5, 4, 3, 2, 1, 0 };
    var fba = std.io.fixedBufferStream(&array);
    var counter = std.io.countingReader(fba.reader());
    const reader = counter.reader();
    try reader.skipBytes(4, .{});
    try skipToBoundary(counter.bytes_read, 4, reader);
    try std.testing.expect(counter.bytes_read == 4);
}
