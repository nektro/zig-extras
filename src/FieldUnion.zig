const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn FieldUnion(comptime T: type) type {
    const infos = std.meta.fields(T);

    var fields: [infos.len]std.builtin.Type.UnionField = undefined;
    inline for (infos, 0..) |field, i| {
        fields[i] = .{
            .name = field.name,
            .type = field.type,
            .alignment = field.alignment,
        };
    }
    return @Type(std.builtin.Type{ .Union = .{
        .layout = .Auto,
        .tag_type = std.meta.FieldEnum(T),
        .fields = &fields,
        .decls = &.{},
    } });
}
