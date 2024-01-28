const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn ptrCast(comptime T: type, ptr: *anyopaque) *T {
    if (@alignOf(T) == 0) @compileError(@typeName(T));
    return @ptrCast(@alignCast(ptr));
}

test {
    var a: u16 = 42;
    const b: *anyopaque = &a;
    const c: *u16 = ptrCast(u16, b);
    try std.testing.expect(a == c.*);
}
