const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn isIndexable(comptime T: type) bool {
    if (comptime is(.Pointer)(T)) {
        if (@typeInfo(T).Pointer.size == .One) {
            return (comptime is(.Array)(std.meta.Child(T)));
        }
        return true;
    }
    return comptime is(.Array)(T) or is(.Vector)(T) or isTuple(T);
}
fn is(comptime id: std.builtin.TypeId) fn (type) bool {
    const Closure = struct {
        pub fn trait(comptime T: type) bool {
            return id == @typeInfo(T);
        }
    };
    return Closure.trait;
}
fn isTuple(comptime T: type) bool {
    return is(.Struct)(T) and @typeInfo(T).Struct.is_tuple;
}

test {
    const array = [_]u8{0} ** 10;
    const slice = @as([]const u8, &array);
    const vector: @Vector(2, u32) = [_]u32{0} ** 2;
    const tuple = .{ 1, 2, 3 };

    try std.testing.expect(isIndexable(@TypeOf(array)));
    try std.testing.expect(isIndexable(@TypeOf(&array)));
    try std.testing.expect(isIndexable(@TypeOf(slice)));
    try std.testing.expect(!isIndexable(std.meta.Child(@TypeOf(slice))));
    try std.testing.expect(isIndexable(@TypeOf(vector)));
    try std.testing.expect(isIndexable(@TypeOf(tuple)));
}
