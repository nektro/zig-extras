const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn isArrayOf(comptime T: type) fn (type) bool {
    const Closure = struct {
        pub fn trait(comptime C: type) bool {
            return switch (@typeInfo(C)) {
                .Array => |ti| ti.child == T,
                else => false,
            };
        }
    };
    return Closure.trait;
}

const L = isArrayOf(u8);
test {
    try std.testing.expect(L([5]u8));
}
test {
    try std.testing.expect(!L([3]u32));
}
test {
    try std.testing.expect(!L(struct { a: u8 }));
}
test {
    try std.testing.expect(!L(enum { a, b, c }));
}
