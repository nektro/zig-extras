const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn readBytesAlloc(reader: anytype, alloc: std.mem.Allocator, len: usize) ![]u8 {
    var list = try std.ArrayListUnmanaged(u8).initCapacity(alloc, len);
    try list.ensureTotalCapacityPrecise(alloc, len);
    errdefer list.deinit(alloc);
    list.appendNTimesAssumeCapacity(0, len);
    try reader.readNoEof(list.items[0..len]);
    return list.items;
}

test {
    const array = [_]u8{ 9, 8, 7, 6, 5, 4, 3, 2, 1, 0 };
    var fba = std.io.fixedBufferStream(&array);
    const reader = fba.reader();
    const alloc = std.testing.allocator;
    const res = try readBytesAlloc(reader, alloc, 2);
    defer alloc.free(res);
    try std.testing.expect(res.len == 2);
    try std.testing.expect(std.mem.eql(u8, res, &.{ 9, 8 }));
}

test {
    const array = [_]u8{ 9, 8, 7, 6, 5, 4, 3, 2, 1, 0 };
    var fba = std.io.fixedBufferStream(&array);
    const reader = fba.reader();
    const alloc = std.testing.allocator;
    try std.testing.expect(readBytesAlloc(reader, alloc, 11) == error.EndOfStream);
}
