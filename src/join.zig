const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn join(input: anytype) Join(@TypeOf(input)) {
    const T = @TypeOf(input);
    var x: Join(T) = undefined;
    inline for (std.meta.fields(T)) |item| {
        inline for (std.meta.fields(item.type)) |f| {
            @field(x, f.name) = @field(@field(input, item.name), f.name);
        }
    }
    return x;
}

pub fn Join(comptime T: type) type {
    var names: []const []const u8 = &.{};
    var types: []const type = &.{};
    inline for (std.meta.fields(T)) |item| {
        inline for (std.meta.fields(item.type)) |f| {
            names = names ++ &[_][]const u8{f.name};
            types = types ++ &[_]type{f.type};
        }
    }
    return @Struct(.auto, null, names, types[0..], &@splat(.{}));
}
