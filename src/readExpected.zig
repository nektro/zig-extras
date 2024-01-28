const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn readExpected(reader: anytype, expected: []const u8) !bool {
    for (expected) |item| {
        const actual = try reader.readByte();
        if (actual != item) {
            return false;
        }
    }
    return true;
}

test {
    std.testing.refAllDecls(@This());
}
