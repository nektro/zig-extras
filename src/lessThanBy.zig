const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn lessThanBy(comptime T: type, comptime field: std.meta.FieldEnum(T)) fn (void, T, T) bool {
    const S = struct {
        pub fn lessThan(_: void, lhs: T, rhs: T) bool {
            return @field(lhs, @tagName(field)) < @field(rhs, @tagName(field));
        }
    };
    return S.lessThan;
}

test {
    const S = struct { x: u32 };
    const l = lessThanBy(S, .x);
    try std.testing.expect(l({}, .{ .x = 19 }, .{ .x = 53 }));
    try std.testing.expect(!l({}, .{ .x = 44 }, .{ .x = 44 }));
    try std.testing.expect(!l({}, .{ .x = 89 }, .{ .x = 26 }));
}
