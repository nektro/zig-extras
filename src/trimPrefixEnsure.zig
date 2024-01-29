const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn trimPrefixEnsure(in: string, prefix: string) ?string {
    if (!std.mem.startsWith(u8, in, prefix)) return null;
    return in[prefix.len..];
}

test {
    try std.testing.expect(trimPrefixEnsure("abaabbaaba", "c") == null);
}
test {
    try std.testing.expect(std.mem.eql(u8, trimPrefixEnsure("abaabbaaba", "aba").?, "abbaaba"));
}
