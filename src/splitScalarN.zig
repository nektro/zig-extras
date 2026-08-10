const std = @import("std");
const extras = @import("./lib.zig");

pub fn splitScalarN(comptime T: type, buffer: []const T, delimiter: T, comptime N: usize) ?[N][]const T {
    var result: [N][]const T = undefined;
    var iter = std.mem.splitScalar(T, buffer, delimiter);
    for (&result) |*x| x.* = iter.next() orelse return null;
    if (iter.next() != null) return null;
    return result;
}

test {
    try std.testing.expectEqualDeep(&[_][]const u8{ "abc", "def" }, &splitScalarN(u8, "abc.def", '.', 2).?);
}
test {
    try std.testing.expectEqual(null, splitScalarN(u8, "abcdef", '.', 2));
}
test {
    try std.testing.expectEqual(null, splitScalarN(u8, "ab.cd.ef", '.', 2));
}
