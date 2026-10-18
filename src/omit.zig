const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn omit(value: anytype, comptime field_name: []const u8) Omit(@TypeOf(value), field_name) {
    const T = @TypeOf(value);
    var result: Omit(T, field_name) = undefined;
    inline for (comptime std.meta.fieldNames(T)) |f| {
        if (comptime std.mem.eql(u8, f, field_name)) continue;
        @field(result, f) = @field(value, f);
    }
    return result;
}

pub fn Omit(T: type, field_name: []const u8) type {
    const info = @typeInfo(T).@"struct";
    const len = info.field_names.len - 1;
    var names: [len][]const u8 = undefined;
    var types: [len]type = undefined;
    var attrs: [len]std.builtin.Type.Struct.FieldAttributes = undefined;
    var i: usize = 0;
    for (info.field_names, info.field_types, info.field_attrs) |f, t, a| {
        if (std.mem.eql(u8, f, field_name)) continue;
        names[i] = f;
        types[i] = t;
        attrs[i] = a;
        i += 1;
    }
    if (i == info.field_names.len) @compileError("struct type " ++ @typeName(T) ++ " does not have a field named \"" ++ field_name ++ "\"");
    return @Struct(.auto, null, &names, &types, &attrs);
}
