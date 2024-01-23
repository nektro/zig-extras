const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn joinPartial(comptime P: type, a: P, b: P) P {
    var temp = a;
    inline for (comptime std.meta.fieldNames(P)) |name| {
        if (@field(b, name)) |val| @field(temp, name) = val;
    }
    return temp;
}
