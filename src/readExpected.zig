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
    const array = [_]u8{ 9, 8, 7, 6, 5, 4, 3, 2, 1, 0 };
    var fba = std.io.fixedBufferStream(&array);
    try std.testing.expect(try readExpected(fba.reader(), &.{ 9, 8, 7, 6 }));
}

test {
    const array = [_]u8{ 9, 8, 7, 6, 5, 4, 3, 2, 1, 0 };
    var fba = std.io.fixedBufferStream(&array);
    try std.testing.expect(!try readExpected(fba.reader(), &.{ 1, 2, 3 }));
}

test {
    const array = [_]u8{ 9, 8, 7, 6, 5, 4, 3, 2, 1, 0 };
    var fba = std.io.fixedBufferStream(&array);
    try std.testing.expect(try readExpected(fba.reader(), &.{}));
}
