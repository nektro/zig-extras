const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn indexBufferT(bytes: [*]const u8, comptime T: type, endian: std.builtin.Endian, idx: usize, max_len: usize) T {
    std.debug.assert(idx < max_len);
    var fbs = std.io.fixedBufferStream((bytes + (idx * @sizeOf(T)))[0..@sizeOf(T)]);
    return extras.readType(fbs.reader(), T, endian) catch |err| switch (err) {
        error.EndOfStream => unreachable, // assert above has been violated
    };
}
