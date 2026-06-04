const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");
const expectSimilarType = extras.expectSimilarType;

pub fn StructOfSlices(T: type) type {
    const info = @typeInfo(T).@"struct";
    const fields = info.fields;
    var names: [fields.len][]const u8 = undefined;
    var types: [fields.len]type = undefined;
    for (fields, 0..) |item, i| {
        names[i] = item.name;
        types[i] = []const item.type;
    }
    return @Struct(.auto, null, &names, &types, &@splat(.{}));
}

test {
    try expectSimilarType(
        StructOfSlices(struct {
            x: u8,
            y: u16,
        }),
        struct {
            x: []const u8,
            y: []const u16,
        },
    );
}
