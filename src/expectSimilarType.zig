const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn expectSimilarType(comptime A: type, comptime B: type) !void {
    const info_a = @typeInfo(A);
    const info_b = @typeInfo(B);
    try std.testing.expect(std.meta.activeTag(info_a) == std.meta.activeTag(info_b));

    if (info_a == .Struct) {
        const info_a_s = info_a.Struct;
        const info_b_s = info_b.Struct;

        try std.testing.expect(info_a_s.layout == info_b_s.layout);
        try std.testing.expect(info_a_s.is_tuple == info_b_s.is_tuple);
        try std.testing.expect(info_a_s.backing_integer == info_b_s.backing_integer);

        for (info_a_s.decls, info_b_s.decls) |da, db| {
            try std.testing.expect(std.mem.eql(u8, da.name, db.name));
        }

        inline for (info_a_s.fields, info_b_s.fields) |fa, fb| {
            try std.testing.expect(std.mem.eql(u8, fa.name, fb.name));
            try std.testing.expect(fa.type == fb.type);
            try std.testing.expect(fa.alignment == fb.alignment);
            try std.testing.expect(fa.is_comptime == fb.is_comptime);
        }

        return;
    }
    if (info_a == .Union) {
        const info_a_u = info_a.Union;
        const info_b_u = info_b.Union;

        try std.testing.expect(info_a_u.layout == info_b_u.layout);
        try expectSimilarType(info_a_u.tag_type.?, info_b_u.tag_type.?);

        for (info_a_u.decls, info_b_u.decls) |da, db| {
            try std.testing.expect(std.mem.eql(u8, da.name, db.name));
        }

        inline for (info_a_u.fields, info_b_u.fields) |fa, fb| {
            try std.testing.expect(std.mem.eql(u8, fa.name, fb.name));
            try std.testing.expect(fa.type == fb.type);
            try std.testing.expect(fa.alignment == fb.alignment);
        }

        return;
    }
    if (info_a == .Enum) {
        const info_a_e = info_a.Enum;
        const info_b_e = info_b.Enum;

        try std.testing.expect(info_a_e.tag_type == info_b_e.tag_type);
        try std.testing.expect(info_a_e.is_exhaustive == info_b_e.is_exhaustive);

        for (info_a_e.decls, info_b_e.decls) |da, db| {
            try std.testing.expect(std.mem.eql(u8, da.name, db.name));
        }

        inline for (info_a_e.fields, info_b_e.fields) |fa, fb| {
            try std.testing.expect(std.mem.eql(u8, fa.name, fb.name));
            try std.testing.expect(fa.value == fb.value);
        }

        return;
    }
    @compileError("not implemented");
}

test {
    try expectSimilarType(
        struct { a: u32, b: u8, c: u16 },
        struct { a: u32, b: u8, c: u16 },
    );
}

test {
    try expectSimilarType(
        union(enum) { a: u32, b: u8, c: u16 },
        union(enum) { a: u32, b: u8, c: u16 },
    );
}

test {
    try expectSimilarType(
        enum { a, b, c, d },
        enum { a, b, c, d },
    );
}
