const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn matchesAny(comptime T: type, haystack: []const T, comptime needle: fn (T) bool) bool {
    for (haystack) |c| {
        if (needle(c)) {
            return true;
        }
    }
    return false;
}
