const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");
const reduceNumber = extras.reduceNumber;

pub fn fmtByteCountIEC(alloc: std.mem.Allocator, b: u64) !string {
    return try reduceNumber(alloc, b, 1024, "B", "KMGTPEZYRQ");
}

test {
    const allocator = std.testing.allocator;
    const actual = try fmtByteCountIEC(allocator, std.math.pow(u64, 1024, 0));
    defer allocator.free(actual);
    try std.testing.expect(std.mem.eql(u8, actual, "1 B"));
}
test {
    const allocator = std.testing.allocator;
    const actual = try fmtByteCountIEC(allocator, std.math.pow(u64, 1024, 1));
    defer allocator.free(actual);
    try std.testing.expect(std.mem.eql(u8, actual, "1.000 KB"));
}
test {
    const allocator = std.testing.allocator;
    const actual = try fmtByteCountIEC(allocator, std.math.pow(u64, 1024, 2));
    defer allocator.free(actual);
    try std.testing.expect(std.mem.eql(u8, actual, "1.000 MB"));
}
test {
    const allocator = std.testing.allocator;
    const actual = try fmtByteCountIEC(allocator, std.math.pow(u64, 1024, 3));
    defer allocator.free(actual);
    try std.testing.expect(std.mem.eql(u8, actual, "1.000 GB"));
}
