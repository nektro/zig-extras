const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn parse_int(comptime T: type, s: ?string, b: u8, d: T) T {
    if (s == null) return d;
    return extras.parseDigits(T, s.?, b) catch d;
}

test {
    try std.testing.expect(parse_int(u32, "25", 10, 13) == 25);
}
test {
    try std.testing.expect(parse_int(u32, "Q", 10, 13) == 13);
}
test {
    try std.testing.expect(parse_int(u32, "", 10, 13) == 13);
}
test {
    try std.testing.expect(parse_int(u32, null, 10, 13) == 13);
}
