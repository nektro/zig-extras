const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn OneSmallerInt(comptime T: type) type {
    var info = @typeInfo(T);
    info.Int.bits -= 1;
    return @Type(info);
}

test {
    try std.testing.expect(OneSmallerInt(u1) == u0);
}
test {
    try std.testing.expect(OneSmallerInt(u2) == u1);
}
test {
    try std.testing.expect(OneSmallerInt(u3) == u2);
}
test {
    try std.testing.expect(OneSmallerInt(u4) == u3);
}
test {
    try std.testing.expect(OneSmallerInt(u5) == u4);
}
test {
    try std.testing.expect(OneSmallerInt(i1) == i0);
}
test {
    try std.testing.expect(OneSmallerInt(i2) == i1);
}
test {
    try std.testing.expect(OneSmallerInt(i3) == i2);
}
test {
    try std.testing.expect(OneSmallerInt(i4) == i3);
}
test {
    try std.testing.expect(OneSmallerInt(i5) == i4);
}
