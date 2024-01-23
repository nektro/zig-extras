const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn parse_bool(s: ?string) bool {
    return extras.parse_int(u1, s, 10, 0) > 0;
}
