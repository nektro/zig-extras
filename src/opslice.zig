const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn opslice(slice: anytype, index: usize) ?std.meta.Elem(@TypeOf(slice)) {
    if (slice.len <= index) return null;
    return slice[index];
}

test {
    const array = [_]u8{ 0, 1, 2, 3, 4, 5 };
    const slice: []const u8 = &array;

    try std.testing.expect(opslice(slice, 0) == 0);
    try std.testing.expect(opslice(slice, 1) == 1);
    try std.testing.expect(opslice(slice, 2) == 2);
    try std.testing.expect(opslice(slice, 3) == 3);
    try std.testing.expect(opslice(slice, 4) == 4);
    try std.testing.expect(opslice(slice, 5) == 5);
    try std.testing.expect(opslice(slice, 6) == null);
}

test {
    const array = [_]u8{ 0, 1, 2, 3, 4, 5 };
    const slice = &array;

    try std.testing.expect(opslice(slice, 0) == 0);
    try std.testing.expect(opslice(slice, 1) == 1);
    try std.testing.expect(opslice(slice, 2) == 2);
    try std.testing.expect(opslice(slice, 3) == 3);
    try std.testing.expect(opslice(slice, 4) == 4);
    try std.testing.expect(opslice(slice, 5) == 5);
    try std.testing.expect(opslice(slice, 6) == null);
}
