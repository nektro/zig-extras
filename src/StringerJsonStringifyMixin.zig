const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn StringerJsonStringifyMixin(comptime S: type) type {
    return struct {
        pub fn jsonStringify(self: S, options: std.json.StringifyOptions, out_stream: anytype) !void {
            var buf: [1024]u8 = undefined;
            var fba = std.heap.FixedBufferAllocator.init(&buf);
            const alloc = fba.allocator();
            var list = std.ArrayList(u8).init(alloc);
            errdefer list.deinit();
            const writer = list.writer();
            try writer.writeAll(try self.toString(alloc));
            try std.json.stringify(list.toOwnedSlice(), options, out_stream);
        }
    };
}
