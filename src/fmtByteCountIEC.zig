const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn fmtByteCountIEC(alloc: std.mem.Allocator, b: u64) !string {
    return try extras.reduceNumber(alloc, b, 1024, "B", "KMGTPEZYRQ");
}
