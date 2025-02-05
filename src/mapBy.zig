const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn mapBy(allocator: std.mem.Allocator, slice: anytype, comptime field: std.meta.FieldEnum(std.meta.Elem(@TypeOf(slice)))) ![]std.meta.FieldType(std.meta.Elem(@TypeOf(slice)), field) {
    const newslice = try allocator.alloc(std.meta.FieldType(std.meta.Elem(@TypeOf(slice)), field), slice.len);
    for (newslice, slice) |*i, j| i.* = @field(j, @tagName(field));
    return newslice;
}

test {
    const alloc = std.testing.allocator;
    const S = struct { x: u32 };
    const original: []const S = &.{ .{ .x = 53 }, .{ .x = 89 }, .{ .x = 19 }, .{ .x = 44 }, .{ .x = 29 } };
    const expected: []const u32 = &.{ 53, 89, 19, 44, 29 };
    const mapped = try mapBy(alloc, original, .x);
    defer alloc.free(mapped);
    try std.testing.expectEqualSlices(u32, expected, mapped);
}
