const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");
const expectSimilarType = extras.expectSimilarType;

pub fn ReverseFields(comptime T: type) type {
    const info = @typeInfo(T).@"struct";
    const len = info.field_names.len;
    var names: [len][]const u8 = undefined;
    var types: [len]type = undefined;
    for (0..len) |i| {
        names[i] = info.field_names[len - 1 - i];
        types[i] = info.field_types[len - 1 - i];
    }
    return @Struct(info.layout, null, &names, &types, &@splat(.{}));
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
