const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn FlippedInt(comptime T: type) type {
    const info = @typeInfo(T).int;
    return @Int(
        switch (info.signedness) {
            .signed => .unsigned,
            .unsigned => .signed,
        },
        info.bits,
    );
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
    try std.testing.expect(FlippedInt(i1) == u1);
}
test {
    try std.testing.expect(FlippedInt(i2) == u2);
}
test {
    try std.testing.expect(FlippedInt(i3) == u3);
}
test {
    try std.testing.expect(FlippedInt(i4) == u4);
}
test {
    try std.testing.expect(FlippedInt(i5) == u5);
}
