const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn hasFields(comptime T: type, comptime names: anytype) bool {
    inline for (names) |name| {
        if (!@hasField(T, name))
            return false;
    }
    return true;
}

test "hasFields" {
    const TestStruct1 = struct {};
    const TestStruct2 = struct {
        a: u32,
        b: u32,
        c: bool,
        pub fn useless() void {}
    };

    const tuple = .{ "a", "b", "c" };

    try std.testing.expect(!hasFields(TestStruct1, .{"a"}));
    try std.testing.expect(hasFields(TestStruct2, .{ "a", "b" }));
    try std.testing.expect(hasFields(TestStruct2, .{ "a", "b", "c" }));
    try std.testing.expect(hasFields(TestStruct2, tuple));
    try std.testing.expect(!hasFields(TestStruct2, .{ "a", "b", "useless" }));
}
