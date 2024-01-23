const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn sliceTo(comptime T: type, haystack: []const T, needle: T) []const T {
    if (std.mem.indexOfScalar(T, haystack, needle)) |index| {
        return haystack[0..index];
    }
    return haystack;
}

test {
    try std.testing.expect(std.mem.eql(u8, sliceTo(u8, "abcdefgh", 'd'), "abc"));
}
test {
    try std.testing.expect(std.mem.eql(u8, sliceTo(u8, "abcdefgh", 'r'), "abcdefgh"));
}
test {
    try std.testing.expect(std.mem.eql(u8, sliceTo(u8, "abcdefgh", 'a'), ""));
}
