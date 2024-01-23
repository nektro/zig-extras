const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn ensureFieldSubset(comptime L: type, comptime R: type) void {
    for (std.meta.fields(L)) |item| {
        if (!@hasField(R, item.name)) @compileError(std.fmt.comptimePrint("{s} is missing the {s} field from {s}", .{ R, item.name, L }));
    }
}
