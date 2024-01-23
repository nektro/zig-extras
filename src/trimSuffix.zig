const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn trimSuffix(in: string, suffix: string) string {
    if (std.mem.endsWith(u8, in, suffix)) {
        return in[0 .. in.len - suffix.len];
    }
    return in;
}
