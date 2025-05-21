const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");
const expectSimilarType = extras.expectSimilarType;

pub fn ReverseFields(comptime T: type) type {
    var info = @typeInfo(T).@"struct";
    const len = info.fields.len;
    var fields: [len]std.builtin.Type.StructField = undefined;
    for (0..len) |i| {
        fields[i] = info.fields[len - 1 - i];
    }
    info.fields = &fields;
    return @Type(.{ .@"struct" = info });
}

test {
    try expectSimilarType(
        ReverseFields(struct {
            x: u8,
            y: u16,
        }),
        struct {
            y: u16,
            x: u8,
        },
    );
}
