const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn containsString(haystack: []const string, needle: string) bool {
    for (haystack) |item| {
        if (std.mem.eql(u8, item, needle)) {
            return true;
        }
    }
    return false;
}
