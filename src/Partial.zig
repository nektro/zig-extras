const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");
const expectSimilarType = extras.expectSimilarType;

/// Creates a new version of struct T where all fields are optional.
/// Name inspried by https://www.typescriptlang.org/docs/handbook/utility-types.html#partialtype.
pub fn Partial(comptime T: type) type {
    const info = @typeInfo(T).@"struct";
    var names: [info.field_names.len][]const u8 = undefined;
    var types: [info.field_types.len]type = undefined;
    var attrs: [info.field_attrs.len]std.builtin.Type.Struct.FieldAttributes = undefined;
    for (info.field_names, info.field_types, 0..) |name, ty, i| {
        names[i] = name;
        types[i] = ?ty;
        attrs[i] = .{ .default_value_ptr = &@as(?ty, null) };
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
