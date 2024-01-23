const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn sum(comptime T: type, slice: []const T) T {
    var res: T = 0;
    for (slice) |item| res += item;
    return res;
}
