const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");
const fileSize = extras.fileSize;

pub fn dirSize(alloc: std.mem.Allocator, dir: std.fs.Dir) !u64 {
    var res: u64 = 0;

    var walk = try dir.walk(alloc);
    defer walk.deinit();
    while (try walk.next()) |entry| {
        if (entry.kind != .file) continue;
        res += try fileSize(dir, entry.path);
    }
    return res;
}

test {
    std.testing.refAllDecls(@This());
}
