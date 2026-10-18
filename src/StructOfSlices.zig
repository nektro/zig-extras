const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");
const expectSimilarType = extras.expectSimilarType;

pub fn StructOfSlices(T: type) type {
    const info = @typeInfo(T).@"struct";
    const field_names = info.field_names;
    const field_types = info.field_types;
    var names: [field_names.len][]const u8 = undefined;
    var types: [field_types.len]type = undefined;
    for (field_names, field_types, 0..) |name, ty, i| {
        names[i] = name;
        types[i] = []const ty;
    }
    if (info.is_tuple) return @Tuple(&types);
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
