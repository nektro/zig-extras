const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn matchesAll(comptime T: type, haystack: []const T, comptime needle: fn (T) bool) bool {
    for (haystack) |c| {
        if (!needle(c)) {
            return false;
        }
    }
    return true;
}

const S = struct {
    fn needle(item: u8) bool {
        return item == 4;
    }
};
test {
    try std.testing.expect(matchesAll(u8, &.{ 4, 4, 4, 4, 4, 4 }, S.needle));
}
test {
    try std.testing.expect(!matchesAll(u8, &.{ 4, 4, 4, 3, 4, 4 }, S.needle));
}
test {
    try std.testing.expect(!matchesAll(u8, &.{ 0, 1, 2, 3, 4, 5 }, S.needle));
}
test {
    try std.testing.expect(!matchesAll(u8, &.{ 5, 6, 7, 8, 9, 0 }, S.needle));
}
