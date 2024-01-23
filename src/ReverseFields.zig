const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn ReverseFields(comptime T: type) type {
    var info = @typeInfo(T).Struct;
    const len = info.fields.len;
    var fields: [len]std.builtin.Type.StructField = undefined;
    for (0..len) |i| {
        fields[i] = info.fields[len - 1 - i];
    }
    info.fields = &fields;
    return @Type(.{ .Struct = info });
}
