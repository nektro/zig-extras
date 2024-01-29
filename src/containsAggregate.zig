const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn containsAggregate(comptime T: type, haystack: []const T, needle: T) bool {
    for (haystack) |item| {
        if (T.eql(item, needle)) {
            return true;
        }
    }
    return false;
}

test {
    const S = struct {
        a: u8,

        fn eql(this: @This(), other: @This()) bool {
            return this.a == other.a;
        }
    };
    const data = [_]S{
        .{ .a = 8 },
        .{ .a = 6 },
        .{ .a = 7 },
        .{ .a = 2 },
        .{ .a = 4 },
        .{ .a = 1 },
        .{ .a = 9 },
        .{ .a = 3 },
        .{ .a = 5 },
    };
    try std.testing.expect(containsAggregate(S, &data, .{ .a = 4 }));
    try std.testing.expect(!containsAggregate(S, &data, .{ .a = 0 }));
}
