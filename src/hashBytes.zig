const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn hashBytes(comptime Algo: type, bytes: []const u8) [Algo.digest_length]u8 {
    var h = Algo.init(.{});
    var out: [Algo.digest_length]u8 = undefined;
    h.update(bytes);
    h.final(&out);
    return out;
}
