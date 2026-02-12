const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

/// Simple number parser with no extra detection or handling. Alphabet is [0-9][a-z] with respect to base.
/// Partially motivated by https://codeberg.org/ziglang/zig/issues/30881 + https://github.com/ziglang/zig/issues/24687
pub fn parseDigits(comptime T: type, buf: []const u8, base: u8) !T {
    std.debug.assert(base > 0);
    std.debug.assert(base <= 36);
    if (buf.len == 0) return error.InvalidCharacter;

    var result: T = 0;
    for (0..buf.len) |i| {
        const c = buf[buf.len - 1 - i];
        const d = switch (c) {
            '0'...'9' => |a| a - '0',
            'a'...'z' => |a| a - 'a' + 10,
            'A'...'Z' => |a| a - 'A' + 10,
            else => return error.InvalidCharacter,
        };
        if (d == 0) continue;
        if (d >= base) return error.Overflow;
        const _x = if (i == 0) 1 else std.math.powi(T, @intCast(base), @intCast(i)) catch return error.Overflow;
        const _y = try std.math.mul(T, @intCast(d), _x);
        const _z = try std.math.add(T, result, _y);
        result = _z;
    }
    return result;
}

test {
    try std.testing.expect(try parseDigits(u8, "10", 10) == 10);
}
test {
    try std.testing.expect(try parseDigits(u8, "20", 16) == 32);
}
test {
    try std.testing.expect(try parseDigits(u8, "EF", 16) == 239);
}
