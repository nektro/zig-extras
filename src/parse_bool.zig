const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");
const parse_int = extras.parse_int;

pub fn parse_bool(s: ?string) bool {
    return parse_int(u1, s, 10, 0) > 0;
}

test {
    try std.testing.expect(parse_bool("1"));
}
test {
    try std.testing.expect(!parse_bool("0"));
}
test {
    try std.testing.expect(!parse_bool("Q"));
}
test {
    try std.testing.expect(!parse_bool(""));
}
test {
    try std.testing.expect(!parse_bool(null));
}
