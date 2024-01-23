const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn to_hex(array: anytype) [array.len * 2]u8 {
    var res: [array.len * 2]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&res);
    std.fmt.format(fbs.writer(), "{x}", .{std.fmt.fmtSliceHexLower(&array)}) catch unreachable;
    return res;
}
