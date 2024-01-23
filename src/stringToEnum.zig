const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn stringToEnum(comptime E: type, str: ?string) ?E {
    return std.meta.stringToEnum(E, str orelse return null);
}
