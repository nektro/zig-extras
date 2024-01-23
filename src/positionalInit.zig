const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn positionalInit(comptime T: type, args: std.meta.FieldsTuple(T)) T {
    var t: T = undefined;
    inline for (std.meta.fields(T), 0..) |field, i| {
        @field(t, field.name) = args[i];
    }
    return t;
}
