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
    @compileError("not implemented");
}

test {
    try expectSimilarType(
        struct { a: u32, b: u8, c: u16 },
        struct { a: u32, b: u8, c: u16 },
    );
}
