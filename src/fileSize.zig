const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn fileSize(dir: std.fs.Dir, sub_path: string) !u64 {
    const f = try dir.openFile(sub_path, .{});
    defer f.close();
    const s = try f.stat();
    return s.size;
}

test {
    std.testing.refAllDecls(@This());
}
