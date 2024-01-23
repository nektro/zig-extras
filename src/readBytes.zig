const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");
const assert = std.debug.assert;

pub fn readBytes(reader: anytype, comptime len: usize) ![len]u8 {
    var bytes: [len]u8 = undefined;
    assert(try reader.readAll(&bytes) == len);
    return bytes;
}
