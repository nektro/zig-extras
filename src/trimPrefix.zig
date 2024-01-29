const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn trimPrefix(in: string, prefix: string) string {
    if (std.mem.startsWith(u8, in, prefix)) {
        return in[prefix.len..];
    }
    return in;
}

test {
    try std.testing.expect(std.mem.eql(u8, trimPrefix("abaabbaaba", "c"), "abaabbaaba"));
}
test {
    try std.testing.expect(std.mem.eql(u8, trimPrefix("abaabbaaba", "aba"), "abbaaba"));
}
