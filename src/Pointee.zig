const std = @import("std");
const extras = @import("./lib.zig");

pub fn Pointee(T: type) type {
    return switch (@typeInfo(T)) {
        .pointer => |p| p.child,
        else => T,
    };
}

test {
    try std.testing.expect(Pointee(u8) == u8);
}
test {
    try std.testing.expect(Pointee(*u8) == u8);
}
