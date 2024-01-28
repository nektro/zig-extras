const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

/// ?A == A fails
/// ?A == @as(?A, b) works
/// Sourced from https://github.com/ziglang/zig/issues/12609
pub fn is(a: anytype, b: @TypeOf(a)) bool {
    return a == b;
}

test {
    try std.testing.expect(is(@as(u8, 5), 5));
}
test {
    try std.testing.expect(is(@as(?u8, 5), 5));
}
test {
    try std.testing.expect(!is(@as(u8, 5), 8));
}
test {
    try std.testing.expect(!is(@as(?u8, 5), 8));
}
