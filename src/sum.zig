const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn sum(comptime T: type, slice: []const T) T {
    var res: T = 0;
    for (slice) |item| res += item;
    return res;
}

test {
    try std.testing.expect(sum(u8, &.{ 4, 3, 0, 9, 6, 7, 1, 2, 5, 8 }) == 45);
}
test {
    try std.testing.expect(sum(u16, &.{ 8, 6, 7, 3, 2, 1, 5, 0, 9, 4 }) == 45);
}
test {
    try std.testing.expect(sum(u21, &.{ 5, 4, 6, 1, 8, 3, 2, 9, 0, 7 }) == 45);
}
test {
    try std.testing.expect(sum(u32, &.{ 3, 4, 5, 1, 9, 0, 6, 2, 7, 8 }) == 45);
}
test {
    try std.testing.expect(sum(u40, &.{ 0, 5, 6, 7, 1, 2, 4, 9, 3, 8 }) == 45);
}
test {
    try std.testing.expect(sum(u64, &.{ 5, 4, 3, 9, 1, 7, 6, 2, 0, 8 }) == 45);
}
