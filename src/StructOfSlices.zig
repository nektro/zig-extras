const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");
const expectSimilarType = extras.expectSimilarType;

pub fn StructOfSlices(T: type) type {
    const info = @typeInfo(T).@"struct";
    const fields = info.fields;
    var new_fields: [fields.len]std.builtin.Type.StructField = undefined;
    for (fields, 0..) |item, i| {
        new_fields[i] = .{
            .name = item.name,
            .type = []const item.type,
            .default_value_ptr = null,
            .is_comptime = false,
            .alignment = @alignOf([]const item.type),
        };
    }
    const result = new_fields[0..fields.len];
    return @Type(@unionInit(std.builtin.Type, "struct", .{
        .layout = .auto,
        .backing_integer = null,
        .fields = result,
        .decls = &.{},
        .is_tuple = info.is_tuple,
    }));
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
