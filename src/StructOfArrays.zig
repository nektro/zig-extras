const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");
const expectSimilarType = extras.expectSimilarType;

pub fn StructOfArrays(len: usize, T: type) type {
    const fields = std.meta.fields(T);
    var new_fields: [fields.len]std.builtin.Type.StructField = undefined;
    for (fields, 0..) |item, i| {
        new_fields[i] = .{
            .name = item.name,
            .type = [len]item.type,
            .default_value = null,
            .is_comptime = false,
            .alignment = @alignOf([len]item.type),
        };
    }
    const result = new_fields[0..fields.len];
    return @Type(@unionInit(std.builtin.Type, "Struct", .{
        .layout = .auto,
        .backing_integer = null,
        .fields = result,
        .decls = &.{},
        .is_tuple = false,
    }));
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
