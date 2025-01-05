const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn indexOfSlice(comptime T: type, haystack: []const []const T, needle: []const T) ?usize {
    for (haystack, 0..) |item, i| {
        if (std.mem.eql(u8, item, needle)) {
            return i;
        }
    }
    return null;
}

test {
    try std.testing.expect(indexOfSlice(u8, &.{ "a", "b", "c", "d" }, "b") == 1);
}
test {
    try std.testing.expect(indexOfSlice(u8, &.{}, "b") == null);
}
