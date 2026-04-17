const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");
const rawIntBytes = extras.rawIntBytes;
const digits = "0123456789abcdef";

const alphabet = blk: {
    var data: [512]u8 = @splat('0');
    for (0..16) |m| {
        for (0..16) |n| {
            data[(m * 16 + n) * 2 + 0] = digits[m];
            data[(m * 16 + n) * 2 + 1] = digits[n];
        }
    }
    const result = data;
    break :blk result;
};

pub fn to_hex(array: anytype) [array.len * 2]u8 {
    var res: [array.len * 2]u8 = undefined;
    for (&array, 0..) |x, i| res[i * 2 ..][0..2].* = alphabet[@as(usize, x) * 2 ..][0..2].*;
    return res;
}

test {
    try std.testing.expect(std.mem.eql(u8, &to_hex(rawIntBytes(u64, 0x4e5a7da9f3f1d132)), "4e5a7da9f3f1d132"));
}
