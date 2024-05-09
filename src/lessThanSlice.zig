const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn lessThanSlice(comptime T: type) fn (void, T, T) bool {
    return struct {
        fn f(_: void, lhs: T, rhs: T) bool {
            const result = for (0..@min(lhs.len, rhs.len)) |i| {
                if (lhs[i] < rhs[i]) break true;
                if (lhs[i] > rhs[i]) break false;
            } else false;
            return result;
        }
    }.f;
}

test {
    try std.testing.expect(lessThanSlice(string)({}, "mouse", "possum"));
}
test {
    try std.testing.expect(!lessThanSlice(string)({}, "mouse", "kangaroo"));
}
test {
    try std.testing.expect(!lessThanSlice(string)({}, "mouse", "mouse"));
}
