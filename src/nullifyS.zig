const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn nullifyS(s: ?string) ?string {
    if (s == null) return null;
    if (s.?.len == 0) return null;
    return s.?;
}
