const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn readBytesAlloc(reader: anytype, alloc: std.mem.Allocator, len: usize) ![]u8 {
    var list = std.ArrayListUnmanaged(u8){};
    try list.ensureTotalCapacityPrecise(alloc, len);
    errdefer list.deinit(alloc);
    list.appendNTimesAssumeCapacity(0, len);
    try reader.readNoEof(list.items[0..len]);
    return list.items;
}
