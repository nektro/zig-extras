const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

/// ?A == A fails
/// ?A == @as(?A, b) works
pub fn is(a: anytype, b: @TypeOf(a)) bool {
    return a == b;
}
