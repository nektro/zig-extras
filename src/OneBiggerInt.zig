const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn OneBiggerInt(comptime T: type) type {
    var info = @typeInfo(T);
    info.Int.bits += 1;
    return @Type(info);
}
