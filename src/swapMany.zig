const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

/// Swap subregions slice[a..][0..an] and slice[b..][0..bn].
/// Subregions may not overlap.
pub fn swapMany(T: type, slice: []T, a: usize, an: usize, b: usize, bn: usize) void {
    if (a == b) return;
    if (a < b) return swapManyLR(T, slice, a, an, b, bn);
    if (a > b) return swapManyLR(T, slice, b, bn, a, an);
    unreachable;
}
pub fn swapManyLR(T: type, slice: []T, a: usize, an: usize, b: usize, bn: usize) void {
    std.debug.assert(a + an <= b);
    std.debug.assert(b + bn <= slice.len);

    if (an == bn) {
        for (0..an, 0..bn) |i, j| {
            std.mem.swap(T, &slice[a + i], &slice[b + j]);
        }
        return;
    }

    const m = @min(an, bn);

    if (an < bn) {
        for (0..m) |i| {
            std.mem.swap(T, &slice[a + i], &slice[b + i]);
        }
        for (m..bn) |i| {
            const temp = slice[b + i];
            std.mem.copyBackwards(
                T,
                slice[a + i + 1 .. b + i + 1],
                slice[a + i .. b + i],
            );
            slice[a + i] = temp;
        }
        return;
    }
    if (an > bn) {
        for (0..m) |i| {
            std.mem.swap(T, &slice[a + i], &slice[b + i]);
        }
        for (m..an) |_| {
            const temp = slice[a + m];
            for (a + m..b + m - 1) |w| slice[w] = slice[w + 1];
            slice[b + m - 1] = temp;
        }
    }
}

test {
    var buf = [_]u8{ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 };
    swapMany(u8, &buf, 2, 3, 6, 3);
    try std.testing.expectEqualSlices(u8, &.{ 0, 1, 6, 7, 8, 5, 2, 3, 4, 9 }, &buf);
}
test {
    var buf = [_]u8{ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 };
    swapMany(u8, &buf, 2, 2, 6, 4);
    try std.testing.expectEqualSlices(u8, &.{ 0, 1, 6, 7, 8, 9, 4, 5, 2, 3 }, &buf);
}
test {
    var buf = [_]u8{ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 };
    swapMany(u8, &buf, 6, 4, 2, 2);
    try std.testing.expectEqualSlices(u8, &.{ 0, 1, 6, 7, 8, 9, 4, 5, 2, 3 }, &buf);
}

test {
    // 43111_ABCDIHEFGJ
    var actual = "ABCDEFGHIJ".*;
    swapMany(u8, &actual, 4, 3, 8, 1);
    try std.testing.expectEqualSlices(u8, "ABCDIHEFGJ", &actual);
}
test {
    // 33121_ABCHIGDEFJ
    var actual = "ABCDEFGHIJ".*;
    swapMany(u8, &actual, 3, 3, 7, 2);
    try std.testing.expectEqualSlices(u8, "ABCHIGDEFJ", &actual);
}
test {
    // 14131_AGHIFBCDEJ
    var actual = "ABCDEFGHIJ".*;
    swapMany(u8, &actual, 1, 4, 6, 3);
    try std.testing.expectEqualSlices(u8, "AGHIFBCDEJ", &actual);
}

comptime {
    @setEvalBranchQuota(20_000);
    for (1..5) |an| {
        for (1..5) |bn| {
            for (1..5) |cn| {
                for (1..5) |dn| {
                    for (1..5) |en| {
                        _ = struct {
                            test {
                                // | a | b | c | d | e |
                                const letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
                                const digits = "0123456789";
                                var i: usize = 0;
                                var j: usize = 0;
                                var a: [an]u8 = undefined;
                                j = 0;
                                while (j < an) : (j += 1) a[j] = letters[i + j];
                                i += an;
                                var b: [bn]u8 = undefined;
                                j = 0;
                                while (j < bn) : (j += 1) b[j] = letters[i + j];
                                i += bn;
                                var c: [cn]u8 = undefined;
                                j = 0;
                                while (j < cn) : (j += 1) c[j] = letters[i + j];
                                i += cn;
                                var d: [dn]u8 = undefined;
                                j = 0;
                                while (j < dn) : (j += 1) d[j] = letters[i + j];
                                i += dn;
                                var e: [en]u8 = undefined;
                                j = 0;
                                while (j < en) : (j += 1) e[j] = letters[i + j];
                                i += en;
                                const key = [_]u8{ digits[an], digits[bn], digits[cn], digits[dn], digits[en], '_' };
                                var actual = key ++ a ++ b ++ c ++ d ++ e;
                                // | a | b | c | d | e |
                                swapMany(
                                    u8,
                                    &actual,
                                    key.len + a.len,
                                    b.len,
                                    key.len + a.len + b.len + c.len,
                                    d.len,
                                );
                                const expected = key ++ a ++ d ++ c ++ b ++ e;
                                try std.testing.expectEqualStrings(&expected, &actual);
                            }
                        };
                    }
                }
            }
        }
    }
}
