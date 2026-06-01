const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn pipe(reader_from: anytype, writer_to: anytype) !void {
    var buf: [4096]u8 = undefined;
    while (true) {
        const n = try reader_from.read(&buf);
        if (n == 0) break;
        try writer_to.writeAll(buf[0..n]);
    }
}

test {
    const bytes = "abcdefghijklmnopqrstuvwxyz".*;
    var fba = std.io.fixedBufferStream(&bytes);
    const allocator = std.testing.allocator;
    var list = std.Io.Writer.Allocating.init(allocator);
    defer list.deinit();
    try pipe(fba.reader(), &list.writer);
    try std.testing.expect(std.mem.eql(u8, &bytes, list.written()));
}
