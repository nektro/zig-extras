const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");
const builtin = @import("builtin");
const native_endian = builtin.target.cpu.arch.endian();
const rawIntBytes = extras.rawIntBytes;

pub fn readType(reader: anytype, comptime T: type, endian: std.builtin.Endian) !T {
    if (T == u8) return reader.readByte(); // single bytes dont have an endianness
    return switch (@typeInfo(T)) {
        .@"struct" => |t| {
            switch (t.layout) {
                .auto, .@"extern" => {
                    var s: T = undefined;
                    inline for (std.meta.fields(T)) |field| {
                        @field(s, field.name) = try readType(reader, field.type, endian);
                    }
                    return s;
                },
                .@"packed" => return @bitCast(try readType(reader, t.backing_integer.?, endian)),
            }
        },
        .array => |t| {
            var s: T = undefined;
            for (0..t.len) |i| {
                s[i] = try readType(reader, t.child, endian);
            }
            return s;
        },
        .int => try reader.readInt(T, endian),
        .@"enum" => |t| @enumFromInt(try readType(reader, t.tag_type, endian)),
        else => |e| @compileError(@tagName(e)),
    };
}

test {
    const bytes = std.mem.toBytes(@as(u32, 0x4e5a7da9));
    var fba = std.io.fixedBufferStream(&bytes);
    const I = u32;
    const i = try readType(fba.reader(), I, native_endian);
    try std.testing.expect(i == 1314553257);
}

test {
    const bytes = std.mem.toBytes(@as(u32, 0x4e5a7da9));
    var fba = std.io.fixedBufferStream(&bytes);
    const E = enum(u32) {
        a,
        b,
        c,
        d = 0x4e5a7da9,
        e,
    };
    const e = try readType(fba.reader(), E, native_endian);
    try std.testing.expect(e == .d);
}

test {
    const bytes = rawIntBytes(u32, 0x4e5a7da9);
    var fba = std.io.fixedBufferStream(&bytes);
    const S = struct {
        a: u16,
        b: u8,
        c: u8,
    };
    const s = try readType(fba.reader(), S, .big);
    try std.testing.expect(s.a == 0x4e5a);
    try std.testing.expect(s.b == 0x7d);
    try std.testing.expect(s.c == 0xa9);
}

test {
    const bytes = rawIntBytes(u32, 0x4e5a7da9);
    var fba = std.io.fixedBufferStream(&bytes);
    const A = [2]u16;
    const a = try readType(fba.reader(), A, .big);
    try std.testing.expect(a[0] == 0x4e5a);
    try std.testing.expect(a[1] == 0x7da9);
}

test {
    const bytes = rawIntBytes(u32, 0x4e5a7da9);
    var fba = std.io.fixedBufferStream(&bytes);
    const S = packed struct {
        a: u16,
        b: u4,
        c: u4,
        d: u8,
    };
    const s = try readType(fba.reader(), S, .big);
    try std.testing.expect(s.a == 0x7da9);
    try std.testing.expect(s.b == 0xa);
    try std.testing.expect(s.c == 0x5);
    try std.testing.expect(s.d == 0x4e);
}
