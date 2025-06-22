const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn countScalar(comptime T: type, haystack: []const T, needle: T) usize {
    var i: usize = 0;
    var found: usize = 0;

    while (std.mem.indexOfScalarPos(T, haystack, i, needle)) |idx| {
        i = idx + 1;
        found += 1;
    }

    return found;
}

test {
    try std.testing.expect(countScalar(u8, "The lazy brown fox jumped over the lazy dog.", ' ') == 8);
}
test {
    try std.testing.expect(countScalar(u8, "kljsklksldajvaskidjklvadv", 'z') == 0);
}
