const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn OneBiggerInt(comptime T: type) type {
    var info = @typeInfo(T);
    info.Int.bits += 1;
    return @Type(info);
}

test {
    try std.testing.expect(OneBiggerInt(u0) == u1);
}
test {
    try std.testing.expect(OneBiggerInt(u1) == u2);
}
test {
    try std.testing.expect(OneBiggerInt(u2) == u3);
}
test {
    try std.testing.expect(OneBiggerInt(u3) == u4);
}
test {
    try std.testing.expect(OneBiggerInt(u4) == u5);
}
test {
    try std.testing.expect(OneBiggerInt(i0) == i1);
}
test {
    try std.testing.expect(OneBiggerInt(i1) == i2);
}
test {
    try std.testing.expect(OneBiggerInt(i2) == i3);
}
test {
    try std.testing.expect(OneBiggerInt(i3) == i4);
}
test {
    try std.testing.expect(OneBiggerInt(i4) == i5);
}
