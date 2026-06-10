const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");
const expectSimilarType = extras.expectSimilarType;

pub fn StructOfArrays(len: usize, T: type) type {
    const info = @typeInfo(T).@"struct";
    const fields = info.fields;
    var names: [fields.len][]const u8 = undefined;
    var types: [fields.len]type = undefined;
    var attrs: [fields.len]std.builtin.Type.StructField.Attributes = undefined;
    for (fields, 0..) |item, i| {
        names[i] = item.name;
        types[i] = [len]item.type;
        attrs[i] = .{
            .@"comptime" = item.is_comptime,
            .@"align" = item.alignment,
            .default_value_ptr = item.default_value_ptr,
        };
    }
    if (info.is_tuple) return @Tuple(&types);
    return @Struct(.auto, null, &names, &types, &attrs);
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
