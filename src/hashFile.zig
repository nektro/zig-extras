const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn hashFile(dir: std.fs.Dir, sub_path: string, comptime Algo: type) ![Algo.digest_length * 2]u8 {
    const file = try dir.openFile(sub_path, .{});
    defer file.close();
    var h = Algo.init(.{});
    var out: [Algo.digest_length]u8 = undefined;
    try extras.pipe(file.reader(), h.writer());
    h.final(&out);
    var res: [Algo.digest_length * 2]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&res);
    try std.fmt.format(fbs.writer(), "{x}", .{std.fmt.fmtSliceHexLower(&out)});
    return res;
}
