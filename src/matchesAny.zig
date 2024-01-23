const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn matchesAny(comptime T: type, haystack: []const T, comptime needle: fn (T) bool) bool {
    for (haystack) |c| {
        if (needle(c)) {
            return true;
        }
    }
    return false;
}

test {
    const S = struct {
        fn needle(item: u8) bool {
            return item == 4;
        }
    };
    try std.testing.expect(matchesAny(u8, &.{ 0, 1, 2, 3, 4, 5 }, S.needle));
}

test {
    const S = struct {
        fn needle(item: u8) bool {
            return item == 7;
        }
    };
    try std.testing.expect(!matchesAny(u8, &.{ 0, 1, 2, 3, 4, 5 }, S.needle));
}
