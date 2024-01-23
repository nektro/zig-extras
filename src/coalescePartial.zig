const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn coalescePartial(comptime T: type, into: T, from: extras.Partial(T)) T {
    var temp = into;
    inline for (comptime std.meta.fieldNames(T)) |name| {
        if (@field(from, name)) |val| @field(temp, name) = val;
    }
    return temp;
}
