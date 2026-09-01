const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn isTuple(comptime T: type) bool {
    return is(.@"struct")(T) and @typeInfo(T).@"struct".is_tuple;
}
fn is(comptime id: std.builtin.TypeId) fn (type) bool {
    const Closure = struct {
        pub fn trait(comptime T: type) bool {
            return id == @typeInfo(T);
        }
    };
    return Closure.trait;
}
