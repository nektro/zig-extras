const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn parse_int(comptime T: type, s: ?string, b: u8, d: T) T {
    if (s == null) return d;
    return std.fmt.parseInt(T, s.?, b) catch d;
}
