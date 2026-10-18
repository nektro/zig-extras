const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");
const expectSimilarType = extras.expectSimilarType;

pub fn StructOfArrays(len: usize, T: type) type {
    const info = @typeInfo(T).@"struct";
    const field_names = info.field_names;
    const field_types = info.field_types;
    const field_attrs = info.field_attrs;
    var names: [field_names.len][]const u8 = undefined;
    var types: [field_types.len]type = undefined;
    var attrs: [field_attrs.len]std.builtin.Type.Struct.FieldAttributes = undefined;
    for (field_names, field_types, field_attrs, 0..) |name, ty, attr, i| {
        names[i] = name;
        types[i] = [len]ty;
        attrs[i] = .{
            .@"comptime" = attr.@"comptime",
            .@"align" = attr.@"align",
            .default_value_ptr = attr.default_value_ptr,
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
