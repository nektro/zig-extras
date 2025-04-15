const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");
const StructOfSlices = extras.StructOfSlices;
const StructOfArrays = extras.StructOfArrays;
const expectSimilarType = extras.expectSimilarType;

pub fn StaticMultiList(T: type) type {
    return struct {
        items: StructOfSlices(T),

        pub fn initComptime(comptime data: []const T) @This() {
            return comptime blk: {
                var temp: StructOfArrays(data.len, T) = undefined;
                for (data, 0..) |item, i| {
                    for (std.meta.fieldNames(T)) |name| {
                        @field(temp, name)[i] = @field(item, name);
                    }
                }
                var result: @This() = undefined;
                for (std.meta.fields(T)) |field| {
                    const constant = @field(temp, field.name)[0..data.len].*;
                    @field(result.items, field.name) = &constant;
                }
                break :blk result;
            };
        }
    };
}

test {
    try expectSimilarType(
        StaticMultiList(struct {
            x: u8,
            y: u16,
        }),
        struct {
            items: struct {
                x: []const u8,
                y: []const u16,
            },
        },
    );
}
