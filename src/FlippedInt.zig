const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn FlippedInt(comptime T: type) type {
    var info = @typeInfo(T);
    info.Int.signedness = switch (info.Int.signedness) {
        .signed => .unsigned,
        .unsigned => .signed,
    };
    return @Type(info);
}

test {
    try std.testing.expect(FlippedInt(u1) == i1);
}
test {
    try std.testing.expect(FlippedInt(u2) == i2);
}
test {
    try std.testing.expect(FlippedInt(u3) == i3);
}
test {
    try std.testing.expect(FlippedInt(u4) == i4);
}
test {
    try std.testing.expect(FlippedInt(u5) == i5);
}
test {
    try std.testing.expect(FlippedInt(i1) == u0);
}
test {
    try std.testing.expect(FlippedInt(i2) == u1);
}
test {
    try std.testing.expect(FlippedInt(i3) == u2);
}
test {
    try std.testing.expect(FlippedInt(i4) == u3);
}
test {
    try std.testing.expect(FlippedInt(i5) == u4);
}
