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

        inline for (info_a_s.field_names, info_a_s.field_types, info_a_s.field_attrs, info_b_s.field_names, info_b_s.field_types, info_b_s.field_attrs) |fa, fat, faa, fb, fbt, fba| {
            try std.testing.expectEqualStrings(fa, fb);
            try expectSimilarType(fat, fbt);
            try std.testing.expectEqual(faa.@"comptime", fba.@"comptime");
            try std.testing.expectEqual(faa.@"align", fba.@"align");
        }

        return;
    }
    if (info_a == .@"union") {
        const info_a_u = info_a.@"union";
        const info_b_u = info_b.@"union";

        try std.testing.expect(info_a_u.layout == info_b_u.layout);
        try expectSimilarType(info_a_u.tag_type.?, info_b_u.tag_type.?);

        inline for (info_a_u.field_names, info_a_u.field_types, info_a_u.field_attrs, info_b_u.field_names, info_b_u.field_types, info_b_u.field_attrs) |fa, fat, faa, fb, fbt, fba| {
            try std.testing.expectEqualStrings(fa, fb);
            try expectSimilarType(fat, fbt);
            try std.testing.expectEqual(faa.@"align", fba.@"align");
        }

        return;
    }
    if (info_a == .@"enum") {
        const info_a_e = info_a.@"enum";
        const info_b_e = info_b.@"enum";

        try std.testing.expect(info_a_e.tag_type == info_b_e.tag_type);
        try std.testing.expect(info_a_e.mode == info_b_e.mode);

        inline for (info_a_e.field_names, info_a_e.field_values, info_b_e.field_names, info_b_e.field_values) |fa, fav, fb, fbv| {
            try std.testing.expectEqualStrings(fa, fb);
            try std.testing.expect(fav == fbv);
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
