const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn doesFileExist(dir: ?std.fs.Dir, fpath: []const u8) !bool {
    const file = (dir orelse std.fs.cwd()).openFile(fpath, .{}) catch |e| switch (e) {
        error.FileNotFound => return false,
        error.IsDir => return true,
        else => return e,
    };
    defer file.close();
    return true;
}

test {
    std.testing.refAllDecls(@This());
}
