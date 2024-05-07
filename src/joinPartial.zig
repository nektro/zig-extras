const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");
const Partial = extras.Partial;

pub fn joinPartial(comptime P: type, a: P, b: P) P {
    var temp = a;
    inline for (comptime std.meta.fieldNames(P)) |name| {
        if (@field(b, name)) |val| @field(temp, name) = val;
    }
    return temp;
}

test {
    const S = struct {
        a: u8 = 4,
        b: u8 = 7,
        c: u8 = 1,
    };
    try std.testing.expect(std.meta.eql(
        joinPartial(
            Partial(S),
            .{ .a = 5 },
            .{ .b = 9 },
        ),
        .{
            .a = 5,
            .b = 9,
            .c = null,
        },
    ));
}
