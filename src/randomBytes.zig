const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn randomBytes(comptime len: usize) [len]u8 {
    var bytes: [len]u8 = undefined;
    std.crypto.random.bytes(&bytes);
    return bytes;
}
