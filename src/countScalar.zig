const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn countScalar(comptime T: type, haystack: []const T, needle: T) usize {
    var found: usize = 0;

    for (haystack) |item| {
        if (item == needle) {
            found += 1;
        }
    }
    return found;
}
