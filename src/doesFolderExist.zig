const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn doesFolderExist(dir: ?std.fs.Dir, fpath: []const u8) !bool {
    const file = (dir orelse std.fs.cwd()).openFile(fpath, .{}) catch |e| switch (e) {
        error.FileNotFound => return false,
        error.IsDir => return true,
        else => return e,
    };
    defer file.close();
    const s = try file.stat();
    if (s.kind != .directory) {
        return false;
    }
    return true;
}

test {
    std.testing.refAllDecls(@This());
}
