const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn sortBySlice(comptime T: type, items: []T, comptime field: std.meta.FieldEnum(T)) void {
    std.mem.sort(T, items, {}, struct {
        fn f(_: void, lhs: T, rhs: T) bool {
            return extras.lessThanSlice(std.meta.FieldType(T, field))({}, @field(lhs, @tagName(field)), @field(rhs, @tagName(field)));
        }
    }.f);
}
