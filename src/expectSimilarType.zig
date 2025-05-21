const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn expectSimilarType(comptime A: type, comptime B: type) !void {
    const info_a = @typeInfo(A);
    const info_b = @typeInfo(B);
    try std.testing.expect(std.meta.activeTag(info_a) == std.meta.activeTag(info_b));

    if (info_a == .@"struct") {
        const info_a_s = info_a.@"struct";
        const info_b_s = info_b.@"struct";

        try std.testing.expect(info_a_s.layout == info_b_s.layout);
        try std.testing.expect(info_a_s.is_tuple == info_b_s.is_tuple);
        try std.testing.expect(info_a_s.backing_integer == info_b_s.backing_integer);

        inline for (info_a_s.fields, info_b_s.fields) |fa, fb| {
            try std.testing.expect(std.mem.eql(u8, fa.name, fb.name));
            try expectSimilarType(fa.type, fb.type);
            try std.testing.expect(fa.alignment == fb.alignment);
            try std.testing.expect(fa.is_comptime == fb.is_comptime);
        }

        return;
    }
    if (info_a == .@"union") {
        const info_a_u = info_a.@"union";
        const info_b_u = info_b.@"union";

        try std.testing.expect(info_a_u.layout == info_b_u.layout);
        try expectSimilarType(info_a_u.tag_type.?, info_b_u.tag_type.?);

        inline for (info_a_u.fields, info_b_u.fields) |fa, fb| {
            try std.testing.expect(std.mem.eql(u8, fa.name, fb.name));
            try expectSimilarType(fa.type, fb.type);
            try std.testing.expect(fa.alignment == fb.alignment);
        }

        return;
    }
    if (info_a == .@"enum") {
        const info_a_e = info_a.@"enum";
        const info_b_e = info_b.@"enum";

        try std.testing.expect(info_a_e.tag_type == info_b_e.tag_type);
        try std.testing.expect(info_a_e.is_exhaustive == info_b_e.is_exhaustive);

        inline for (info_a_e.fields, info_b_e.fields) |fa, fb| {
            try std.testing.expect(std.mem.eql(u8, fa.name, fb.name));
            try std.testing.expect(fa.value == fb.value);
        }

        return;
    }
    try std.testing.expect(A == B);
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
