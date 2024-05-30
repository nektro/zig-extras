const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");
const root = @import("root");

pub fn globalOption(comptime T: type, comptime name: []const u8) ?T {
    if (!@hasDecl(root, name)) return null;
    return @as(T, @field(root, name));
}
