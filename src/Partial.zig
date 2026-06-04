const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");
const expectSimilarType = extras.expectSimilarType;

/// Creates a new version of struct T where all fields are optional.
/// Name inspried by https://www.typescriptlang.org/docs/handbook/utility-types.html#partialtype.
pub fn Partial(comptime T: type) type {
    const fields = std.meta.fields(T);
    var names: [fields.len][]const u8 = undefined;
    var types: [fields.len]type = undefined;
    var attrs: [fields.len]std.builtin.Type.StructField.Attributes = undefined;
    for (fields, 0..) |item, i| {
        names[i] = item.name;
        types[i] = ?item.type;
        attrs[i] = .{ .default_value_ptr = &@as(?item.type, null) };
    }
    return @Struct(.auto, null, &names, &types, &attrs);
}

test {
    try expectSimilarType(
        Partial(struct {
            a: u32,
            b: u8,
            c: u16,
        }),
        struct {
            a: ?u32,
            b: ?u8,
            c: ?u16,
        },
    );
}

test {
    try expectSimilarType(
        Partial(struct {
            a: ?u8,
        }),
        struct {
            a: ??u8,
        },
    );
}
