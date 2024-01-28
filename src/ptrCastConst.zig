const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn ptrCastConst(comptime T: type, ptr: *const anyopaque) *const T {
    if (@alignOf(T) == 0) @compileError(@typeName(T));
    return @ptrCast(@alignCast(ptr));
}

test {
    const a: u16 = 42;
    const b: *const anyopaque = &a;
    const c: *const u16 = ptrCastConst(u16, b);
    try std.testing.expect(a == c.*);
}
