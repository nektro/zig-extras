const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn Partial(comptime T: type) type {
    const fields_before = std.meta.fields(T);
    var fields_after: [fields_before.len]std.builtin.Type.StructField = undefined;
    inline for (fields_before, 0..) |item, i| {
        fields_after[i] = std.builtin.Type.StructField{
            .name = item.name,
            .type = ?item.type,
            .default_value = &@as(?item.type, null),
            .is_comptime = false,
            .alignment = @alignOf(?item.type),
        };
    }
    return @Type(@unionInit(std.builtin.Type, "Struct", .{
        .layout = .Auto,
        .backing_integer = null,
        .fields = &fields_after,
        .decls = &.{},
        .is_tuple = false,
    }));
}
