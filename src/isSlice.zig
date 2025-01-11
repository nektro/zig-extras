const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn isSlice(comptime T: type) bool {
    if (comptime is(.Pointer)(T)) {
        if (@typeInfo(T).Pointer.size == .Slice) return true;
        if (@typeInfo(T).Pointer.size == .One and is(.Array)(std.meta.Child(T))) return true;
    }
    return false;
}
fn is(comptime id: std.builtin.TypeId) fn (type) bool {
    const Closure = struct {
        pub fn trait(comptime T: type) bool {
            return id == @typeInfo(T);
        }
    };
    return Closure.trait;
}

test {
    const array = [_]u8{0} ** 10;
    var runtime_zero: usize = 0;
    _ = &runtime_zero;
    try std.testing.expect(isSlice(@TypeOf(array[runtime_zero..])));
    try std.testing.expect(!isSlice(@TypeOf(array)));
    try std.testing.expect(!isSlice(@TypeOf(&array[0])));
}

test {
    try std.testing.expect(isSlice(@TypeOf(&[_]u32{ 66, 81, 99, 24, 36, 65, 24, 19, 25, 44 })));
}
