const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");
const expectSimilarType = extras.expectSimilarType;

pub fn FieldUnion(comptime T: type) type {
    const fields = std.meta.fields(T);
    var names: [fields.fields.len][]const u8 = undefined;
    var types: [fields.fields.len]type = undefined;
    var attrs: [fields.fields.len]std.builtin.Type.UnionField.Attributes = undefined;

    inline for (fields, 0..) |field, i| {
        names[i] = field.name;
        types[i] = field.type;
        attrs[i] = .{ .@"align" = field.alignment };
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
