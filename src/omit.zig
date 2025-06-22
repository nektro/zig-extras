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
    var fields: [fields_original.len - 1]std.builtin.Type.StructField = undefined;
    var i: usize = 0;
    for (fields_original) |f| {
        if (std.mem.eql(u8, f.name, field_name)) continue;
        fields[i] = f;
        i += 1;
    }
    return @Type(.{ .@"struct" = .{ .layout = .auto, .fields = &fields, .decls = &.{}, .is_tuple = false } });
}
