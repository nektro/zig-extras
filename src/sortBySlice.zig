const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");
const lessThanSlice = extras.lessThanSlice;

pub fn sortBySlice(comptime T: type, items: []T, comptime field: std.meta.FieldEnum(T)) void {
    std.mem.sort(T, items, {}, struct {
        fn f(_: void, lhs: T, rhs: T) bool {
            return lessThanSlice(std.meta.FieldType(T, field))({}, @field(lhs, @tagName(field)), @field(rhs, @tagName(field)));
        }
    }.f);
}

test {
    const Block = struct {
        from: u21,
        to: u21,
        name: []const u8,
    };
    var data = [_]Block{
        .{ .from = 0x0000, .to = 0x007F, .name = "Basic Latin" },
        .{ .from = 0x0080, .to = 0x00FF, .name = "Latin-1 Supplement" },
        .{ .from = 0x0180, .to = 0x024F, .name = "Latin Extended-B" },
        .{ .from = 0x0100, .to = 0x017F, .name = "Latin Extended-A" },
        .{ .from = 0x0250, .to = 0x02AF, .name = "IPA Extensions" },
    };
    sortBySlice(Block, &data, .name);
    try std.testing.expect(std.mem.eql(u8, data[0].name, "Basic Latin"));
    try std.testing.expect(std.mem.eql(u8, data[1].name, "IPA Extensions"));
    try std.testing.expect(std.mem.eql(u8, data[2].name, "Latin Extended-A"));
    try std.testing.expect(std.mem.eql(u8, data[3].name, "Latin Extended-B"));
    try std.testing.expect(std.mem.eql(u8, data[4].name, "Latin-1 Supplement"));
}
