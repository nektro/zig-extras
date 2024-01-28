const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn pipe(reader_from: anytype, writer_to: anytype) !void {
    var buf: [std.mem.page_size]u8 = undefined;
    var fifo = std.fifo.LinearFifo(u8, .Slice).init(&buf);
    defer fifo.deinit();
    try fifo.pump(reader_from, writer_to);
}

test {
    const bytes = "abcdefghijklmnopqrstuvwxyz".*;
    var fba = std.io.fixedBufferStream(&bytes);
    const allocator = std.testing.allocator;
    var list = std.ArrayList(u8).init(allocator);
    defer list.deinit();
    try pipe(fba.reader(), list.writer());
    try std.testing.expect(std.mem.eql(u8, &bytes, list.items));
}
