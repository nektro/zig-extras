const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");
const reduceNumber = extras.reduceNumber;

pub fn fmtByteCountIEC(b: u64) std.fmt.Alt(u64, formatByteCountIEC) {
    return .{ .data = b };
}

fn formatByteCountIEC(bytes: u64, writer: *std.Io.Writer) !void {
    try reduceNumber(writer, bytes, 1024, "B", "KMGTPEZYRQ");
}

test {
    try std.testing.expectFmt("1 B", "{f}", .{fmtByteCountIEC(std.math.pow(u64, 1024, 0))});
}
test {
    try std.testing.expectFmt("1.000 KB", "{f}", .{fmtByteCountIEC(std.math.pow(u64, 1024, 1))});
}
test {
    try std.testing.expectFmt("1.000 MB", "{f}", .{fmtByteCountIEC(std.math.pow(u64, 1024, 2))});
}
test {
    try std.testing.expectFmt("1.000 GB", "{f}", .{fmtByteCountIEC(std.math.pow(u64, 1024, 3))});
}
