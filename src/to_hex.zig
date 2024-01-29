const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");
const rawIntBytes = extras.rawIntBytes;

pub fn to_hex(array: anytype) [array.len * 2]u8 {
    var res: [array.len * 2]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&res);
    std.fmt.format(fbs.writer(), "{x}", .{std.fmt.fmtSliceHexLower(&array)}) catch unreachable;
    return res;
}

test {
    try std.testing.expect(std.mem.eql(u8, &to_hex(rawIntBytes(u64, 0x4e5a7da9f3f1d132)), "4e5a7da9f3f1d132"));
}
