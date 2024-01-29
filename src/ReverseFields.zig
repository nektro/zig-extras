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

test {
    const A = struct { x: u8, y: u16 };
    const B = ReverseFields(A);
    const fields = std.meta.fields(B);

    try std.testing.expect(fields.len == 2);
    try std.testing.expect(fields[0].type == u16);
    try std.testing.expect(std.mem.eql(u8, fields[0].name, "y"));
    try std.testing.expect(fields[1].type == u8);
    try std.testing.expect(std.mem.eql(u8, fields[1].name, "x"));
}
