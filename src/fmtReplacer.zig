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

const FormatData = struct {
    bytes: string,
    from: u8,
    to: u8,
};

fn formatReplacer(
    self: FormatData,
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

test {
    const in = "C:\\Program Files\\Custom Utilities\\StringFinder.exe";
    const out = "C:/Program Files/Custom Utilities/StringFinder.exe";
    try std.testing.expectFmt(out, "{}", .{fmtReplacer(in, '\\', '/')});
}
