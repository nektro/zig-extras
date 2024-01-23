const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn containsAggregate(comptime T: type, haystack: []const T, needle: T) bool {
    for (haystack) |item| {
        if (T.eql(item, needle)) {
            return true;
        }
    }
    return false;
}
