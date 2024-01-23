const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn matchesAll(comptime T: type, haystack: []const T, comptime needle: fn (T) bool) bool {
    for (haystack) |c| {
        if (!needle(c)) {
            return false;
        }
    }
    return true;
}
