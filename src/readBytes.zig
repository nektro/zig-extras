const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");
const assert = std.debug.assert;

pub fn readBytes(reader: anytype, comptime len: usize) ![len]u8 {
    var bytes: [len]u8 = undefined;
    if (try reader.readAll(&bytes) != len) return error.EndOfStream;
    return bytes;
}

test {
    const array = [_]u8{ 9, 8, 7, 6, 5, 4, 3, 2, 1, 0 };
    var fba = std.io.fixedBufferStream(&array);
    const reader = fba.reader();
    const res = try readBytes(reader, 2);
    try std.testing.expect(res.len == 2);
    try std.testing.expect(std.mem.eql(u8, &res, &.{ 9, 8 }));
}

test {
    const array = [_]u8{ 9, 8, 7, 6, 5, 4, 3, 2, 1, 0 };
    var fba = std.io.fixedBufferStream(&array);
    const reader = fba.reader();
    try std.testing.expect(readBytes(reader, 13) == error.EndOfStream);
}
