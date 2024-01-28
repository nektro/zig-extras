const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");
const pipe = extras.pipe;
const rawInt = extras.rawInt;

pub fn hashFile(dir: std.fs.Dir, sub_path: string, comptime Algo: type) ![Algo.digest_length * 2]u8 {
    const file = try dir.openFile(sub_path, .{});
    defer file.close();
    var h = Algo.init(.{});
    var out: [Algo.digest_length]u8 = undefined;
    try pipe(file.reader(), h.writer());
    h.final(&out);
    var res: [Algo.digest_length * 2]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&res);
    try std.fmt.format(fbs.writer(), "{x}", .{std.fmt.fmtSliceHexLower(&out)});
    return res;
}

test {
    const tdir = std.testing.tmpDir(.{}).dir;
    try tdir.writeFile("yo.txt", "hello");
    const A = std.crypto.hash.sha2.Sha256;
    const expected = "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824".*;
    try std.testing.expect(std.mem.eql(u8, &try hashFile(tdir, "yo.txt", A), &expected));
}
