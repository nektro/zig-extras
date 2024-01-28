const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn TagNameJsonStringifyMixin(comptime S: type) type {
    return struct {
        pub fn jsonStringify(self: S, json_stream: anytype) !void {
            try json_stream.write(@tagName(self));
        }
    };
}

test {
    const E = enum {
        windows,
        linux,
        macos,
        freebsd,

        pub usingnamespace TagNameJsonStringifyMixin(@This());
    };
    const allocator = std.testing.allocator;
    var str = std.ArrayList(u8).init(allocator);
    defer str.deinit();
    try std.json.stringify(@as(E, .linux), .{}, str.writer());
    try std.testing.expect(std.mem.eql(u8, str.items, "\"linux\""));
}
