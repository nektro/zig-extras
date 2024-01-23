const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn opslice(slice: anytype, index: usize) ?std.meta.Child(@TypeOf(slice)) {
    if (slice.len <= index) return null;
    return slice[index];
}
