const std = @import("std");
const extras = @import("./lib.zig");

pub fn omitSlice(allocator: std.mem.Allocator, T: type, slice: []const T, comptime field_names: []const []const u8) ![]OmitSlice(T, field_names) {
    const E = OmitSlice(T, field_names);
    const result = try allocator.alloc(E, slice.len);
    for (slice, result) |v, *w| {
        inline for (@typeInfo(E).@"struct".fields) |f| {
            @field(w, f.name) = @field(v, f.name);
        }
    }
    return result;
}

pub fn OmitSlice(T: type, field_names: []const []const u8) type {
    if (field_names.len == 0) return T;
    return extras.Omit(OmitSlice(T, field_names[1..]), field_names[0]);
}
