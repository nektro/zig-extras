const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn omit(value: anytype, comptime field_name: []const u8) Omit(@TypeOf(value), field_name) {
    const T = @TypeOf(value);
    var result: Omit(T, field_name) = undefined;
    inline for (comptime std.meta.fields(T)) |f| {
        if (comptime std.mem.eql(u8, f.name, field_name)) continue;
        @field(result, f.name) = @field(value, f.name);
    }
    return result;
}

pub fn Omit(T: type, field_name: []const u8) type {
    const fields_original = std.meta.fields(T);
    const len = fields_original.len - 1;
    var names: [len][]const u8 = undefined;
    var types: [len]type = undefined;
    var attrs: [len]std.builtin.Type.StructField.Attributes = undefined;
    var i: usize = 0;
    for (fields_original) |f| {
        if (std.mem.eql(u8, f.name, field_name)) continue;
        names[i] = f.name;
        types[i] = f.type;
        attrs[i] = .{
            .@"comptime" = f.is_comptime,
            .@"align" = f.alignment,
            .default_value_ptr = f.default_value_ptr,
        };
        i += 1;
    }
    return @Struct(.auto, null, &names, &types, &attrs);
    // return @Type(.{ .@"struct" = .{ .layout = .auto, .fields = &fields, .decls = &.{}, .is_tuple = false } });
}
