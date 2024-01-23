const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn fileList(alloc: std.mem.Allocator, dir: std.fs.IterableDir) ![]string {
    var list = std.ArrayList(string).init(alloc);
    defer list.deinit();

    var walk = try dir.walk(alloc);
    defer walk.deinit();
    while (try walk.next()) |entry| {
        if (entry.kind != .file) continue;
        try list.append(try alloc.dupe(u8, entry.path));
    }
    return list.toOwnedSlice();
}
