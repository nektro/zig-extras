const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn trimPrefixEnsure(in: string, prefix: string) ?string {
    if (!std.mem.startsWith(u8, in, prefix)) return null;
    return in[prefix.len..];
}
