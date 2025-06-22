const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn join(input: anytype) Join(@TypeOf(input)) {
    const T = @TypeOf(input);
    var x: Join(T) = undefined;
    inline for (std.meta.fields(T)) |item| {
        inline for (std.meta.fields(item.type)) |f| {
            @field(x, f.name) = @field(@field(input, item.name), f.name);
        }
    }
    return x;
}

pub fn Join(comptime T: type) type {
    var fields: []const std.builtin.Type.StructField = &.{};
    inline for (std.meta.fields(T)) |item| {
        inline for (std.meta.fields(item.type)) |f| {
            fields = fields ++ &[_]std.builtin.Type.StructField{.{
                .name = f.name,
                .type = f.type,
                .default_value_ptr = null,
                .is_comptime = false,
                .alignment = @alignOf(f.type),
            }};
        }
    }
    return @Type(.{ .@"struct" = .{ .layout = .auto, .fields = fields, .decls = &.{}, .is_tuple = false } });
}
