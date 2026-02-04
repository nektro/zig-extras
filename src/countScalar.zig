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

test {
    try std.testing.expect(countScalar(u8, "The lazy brown fox jumped over the lazy dog.", ' ') == 8);
}
test {
    try std.testing.expect(countScalar(u8, "kljsklksldajvaskidjklvadv", 'z') == 0);
}
