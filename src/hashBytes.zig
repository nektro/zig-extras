const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");
const rawIntBytes = extras.rawIntBytes;

pub fn hashBytes(comptime Algo: type, bytes: []const u8) [Algo.digest_length]u8 {
    var h = Algo.init(.{});
    var out: [Algo.digest_length]u8 = undefined;
    h.update(bytes);
    h.final(&out);
    return out;
}

test {
    const A = std.crypto.hash.Md5;
    try std.testing.expect(std.mem.eql(u8, &hashBytes(A, "hello"), &rawIntBytes(u128, 0x5d41402abc4b2a76b9719d911017c592)));
}

test {
    const A = std.crypto.hash.Sha1;
    // by default the array len is 24 for u160
    try std.testing.expect(std.mem.eql(u8, &hashBytes(A, "hello"), &rawIntBytes(u160, 0xaaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d)));
}

test {
    const A = std.crypto.hash.sha2.Sha256;
    try std.testing.expect(std.mem.eql(u8, &hashBytes(A, "hello"), &rawIntBytes(u256, 0x2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824)));
}
