const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");
const Partial = extras.Partial;

pub fn coalescePartial(comptime T: type, into: T, from: Partial(T)) T {
    var temp = into;
    inline for (comptime std.meta.fieldNames(T)) |name| {
        if (@field(from, name)) |val| @field(temp, name) = val;
    }
    return temp;
}

test {
    const S = struct {
        a: u8 = 4,
        b: u8 = 7,
        c: u8 = 1,
    };
    try std.testing.expect(std.meta.eql(coalescePartial(S, .{}, .{ .b = 9 }), .{
        .a = 4,
        .b = 9,
        .c = 1,
    }));
}
