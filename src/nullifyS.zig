const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn nullifyS(s: ?string) ?string {
    if (s == null) return null;
    if (s.?.len == 0) return null;
    return s.?;
}

test {
    try std.testing.expect(nullifyS(null) == null);
}
test {
    try std.testing.expect(nullifyS("") == null);
}
test {
    try std.testing.expect(nullifyS("a") != null);
    try std.testing.expect(nullifyS("a").?.len == 1);
    try std.testing.expect(nullifyS("a").?[0] == 'a');
}
