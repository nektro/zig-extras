const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn maxLen(comptime T: type, slice: []const []const T) usize {
    var res: usize = 0;
    for (slice) |item| res = @max(res, item.len);
    return res;
}

test {
    try std.testing.expect(maxLen(u21, &.{ &.{ 5, 4, 6 }, &.{ 1, 8, 3, 2 }, &.{ 9, 0, 7 } }) == 4);
}
