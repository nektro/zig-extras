const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn isContainer(comptime T: type) bool {
    return switch (@typeInfo(T)) {
        .Struct,
        .Union,
        .Enum,
        .Opaque,
        => true,
        else => false,
    };
}

test {
    const TestStruct = struct {};
    const TestUnion = union {
        a: void,
    };
    const TestEnum = enum {
        A,
        B,
    };
    const TestOpaque = opaque {};

    try std.testing.expect(isContainer(TestStruct));
    try std.testing.expect(isContainer(TestUnion));
    try std.testing.expect(isContainer(TestEnum));
    try std.testing.expect(isContainer(TestOpaque));
    try std.testing.expect(!isContainer(u8));
}
