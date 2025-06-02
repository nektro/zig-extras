const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");
const reduceNumber = extras.reduceNumber;

pub fn fmtByteCountIEC(b: u64) std.fmt.Formatter(formatByteCountIEC) {
    return .{ .data = b };
}

fn formatByteCountIEC(bytes: u64, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
    _ = fmt;
    _ = options;
    try reduceNumber(writer, bytes, 1024, "B", "KMGTPEZYRQ");
}

test {
    try std.testing.expectFmt("1 B", "{}", .{fmtByteCountIEC(std.math.pow(u64, 1024, 0))});
}
test {
    try std.testing.expectFmt("1.000 KB", "{}", .{fmtByteCountIEC(std.math.pow(u64, 1024, 1))});
}
test {
    try std.testing.expectFmt("1.000 MB", "{}", .{fmtByteCountIEC(std.math.pow(u64, 1024, 2))});
}
test {
    try std.testing.expectFmt("1.000 GB", "{}", .{fmtByteCountIEC(std.math.pow(u64, 1024, 3))});
}
