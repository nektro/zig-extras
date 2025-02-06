const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");
const root = @import("root");

pub fn globalOption(comptime name: []const u8, comptime T: type) ?T {
    if (!@hasDecl(root, name)) return null;
    return @as(T, @field(root, name));
}
