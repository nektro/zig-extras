const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn ptrCast(comptime T: type, ptr: *anyopaque) *T {
    if (@alignOf(T) == 0) @compileError(@typeName(T));
    return @ptrCast(@alignCast(ptr));
}
