const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn parse_json(alloc: std.mem.Allocator, input: string) !std.json.Parsed(std.json.Value) {
    return std.json.parseFromSlice(std.json.Value, alloc, input, .{});
}
