const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");
const expectSimilarType = extras.expectSimilarType;

pub fn FieldUnion(comptime T: type) type {
    const info = @typeInfo(T).@"struct";
    var names: [info.field_names.len][]const u8 = undefined;
    var types: [info.field_types.len]type = undefined;
    var attrs: [info.field_attrs.len]std.builtin.Type.Union.FieldAttributes = undefined;
    inline for (info.field_names, info.field_types, info.field_attrs, 0..) |field, ty, attr, i| {
        names[i] = field;
        types[i] = ty;
        attrs[i] = .{ .@"align" = attr.@"align" };
    }
    return @Union(.auto, std.meta.FieldEnum(T), &names, &types, &attrs);
}

test {
    try expectSimilarType(
        FieldUnion(struct {
            a: u32,
            b: u8,
            c: u16,
        }),
        union(enum) {
            a: u32,
            b: u8,
            c: u16,
        },
    );
}
