const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn dirSize(alloc: std.mem.Allocator, dir: std.fs.IterableDir) !u64 {
    var res: u64 = 0;

    var walk = try dir.walk(alloc);
    defer walk.deinit();
    while (try walk.next()) |entry| {
        if (entry.kind != .File) continue;
        res += try extras.fileSize(dir.dir, entry.path);
    }
    return res;
}
