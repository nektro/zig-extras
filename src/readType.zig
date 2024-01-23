const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn readType(reader: anytype, comptime T: type, endian: std.builtin.Endian) !T {
    if (T == u8) return reader.readByte(); // single bytes dont have an endianness
    return switch (@typeInfo(T)) {
        .Struct => |t| {
            switch (t.layout) {
                .Auto, .Extern => {
                    var s: T = undefined;
                    inline for (std.meta.fields(T)) |field| {
                        @field(s, field.name) = try readType(reader, field.type, endian);
                    }
                    return s;
                },
                .Packed => return @bitCast(try readType(reader, t.backing_integer.?, endian)),
            }
        },
        .Array => |t| {
            var s: T = undefined;
            for (0..t.len) |i| {
                s[i] = try readType(reader, t.child, endian);
            }
            return s;
        },
        .Int => try reader.readInt(T, endian),
        .Enum => |t| @enumFromInt(try readType(reader, t.tag_type, endian)),
        else => |e| @compileError(@tagName(e)),
    };
}
