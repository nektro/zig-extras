const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn TagNameJsonStringifyMixin(comptime S: type) type {
    return struct {
        pub fn jsonStringify(self: S, options: std.json.StringifyOptions, out_stream: anytype) !void {
            try std.json.stringify(@tagName(self), options, out_stream);
        }
    };
}
