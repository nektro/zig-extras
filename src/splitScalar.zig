const std = @import("std");
const extras = @import("./lib.zig");

pub fn splitScalar(comptime T: type, buffer: []const T, delimiter: T, allocator: std.mem.Allocator) ![][]const T {
    var list: std.ArrayList([]const T) = .empty;
    defer list.deinit(allocator);
    var iter = std.mem.splitScalar(T, buffer, delimiter);
    while (iter.next()) |item| try list.append(allocator, item);
    return list.toOwnedSlice(allocator);
}

test {
    const allocator = std.testing.allocator;
    const cut = try splitScalar(u8, "ab.cd.ef", '.', allocator);
    defer allocator.free(cut);
    try std.testing.expectEqualDeep(&[_][]const u8{ "ab", "cd", "ef" }, cut);
}
