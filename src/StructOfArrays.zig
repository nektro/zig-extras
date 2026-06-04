const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");
const expectSimilarType = extras.expectSimilarType;

pub fn StructOfArrays(len: usize, T: type) type {
    const info = @typeInfo(T).@"struct";
    const fields = info.fields;
    var names: [fields.len][]const u8 = undefined;
    var types: [fields.len]type = undefined;
    for (fields, 0..) |item, i| {
        names[i] = item.name;
        types[i] = [len]item.type;
    }
    return @Struct(.auto, null, &names, &types, &@splat(.{}));
}

test {
    try expectSimilarType(
        StructOfArrays(10, struct {
            x: u8,
            y: u16,
        }),
        struct {
            x: [10]u8,
            y: [10]u16,
        },
    );
}
