const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn sliceTo(comptime T: type, haystack: []const T, needle: T) []const T {
    if (std.mem.indexOfScalar(T, haystack, needle)) |index| {
        return haystack[0..index];
    }
    return haystack;
}
