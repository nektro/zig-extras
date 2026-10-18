const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn join(input: anytype) Join(@TypeOf(input)) {
    const T = @TypeOf(input);
    var x: Join(T) = undefined;
    inline for (comptime std.meta.fieldNames(T), comptime std.meta.fieldTypes(T)) |item, ttem| {
        inline for (comptime std.meta.fieldNames(ttem)) |f| {
            @field(x, f) = @field(@field(input, item), f);
        }
    }
    return x;
}

pub fn Join(comptime T: type) type {
    var names: []const []const u8 = &.{};
    var types: []const type = &.{};
    inline for (std.meta.fieldTypes(T)) |item| {
        inline for (std.meta.fieldNames(item), std.meta.fieldTypes(item)) |f, t| {
            names = names ++ &[_][]const u8{f};
            types = types ++ &[_]type{t};
        }
    }
    return @Struct(.auto, null, names, types[0..], &@splat(.{}));
}
