const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn fmtReplacer(bytes: string, from: u8, to: u8) std.fmt.Formatter(formatReplacer) {
    return .{ .data = .{
        .bytes = bytes,
        .from = from,
        .to = to,
    } };
}

fn formatReplacer(
    self: struct {
        bytes: string,
        from: u8,
        to: u8,
    },
    comptime fmt: []const u8,
    options: std.fmt.FormatOptions,
    writer: anytype,
) !void {
    _ = fmt;
    _ = options;
    for (self.bytes) |c| {
        try writer.writeByte(if (c == self.from) self.to else @intCast(c));
    }
}
