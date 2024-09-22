const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

/// Returns true if the passed type will coerce to []const u8.
/// Any of the following are considered strings:
/// ```
/// []const u8, [:S]const u8, *const [N]u8, *const [N:S]u8,
/// []u8, [:S]u8, *[:S]u8, *[N:S]u8.
/// ```
/// These types are not considered strings:
/// ```
/// u8, [N]u8, [*]const u8, [*:0]const u8,
/// [*]const [N]u8, []const u16, []const i8,
/// *const u8, ?[]const u8, ?*const [N]u8.
/// ```
pub fn isZigString(comptime T: type) bool {
    return comptime blk: {
        // Only pointer types can be strings, no optionals
        const info = @typeInfo(T);
        if (info != .Pointer) break :blk false;

        const ptr = &info.Pointer;
        // Check for CV qualifiers that would prevent coerction to []const u8
        if (ptr.is_volatile or ptr.is_allowzero) break :blk false;

        // If it's already a slice, simple check.
        if (ptr.size == .Slice) {
            break :blk ptr.child == u8;
        }

        // Otherwise check if it's an array type that coerces to slice.
        if (ptr.size == .One) {
            const child = @typeInfo(ptr.child);
            if (child == .Array) {
                const arr = &child.Array;
                break :blk arr.child == u8;
            }
        }

        break :blk false;
    };
}

test {
    try std.testing.expect(isZigString([]const u8));
}
test {
    try std.testing.expect(isZigString([]u8));
}
test {
    try std.testing.expect(isZigString([:0]const u8));
}
test {
    try std.testing.expect(isZigString([:0]u8));
}
test {
    try std.testing.expect(isZigString([:5]const u8));
}
test {
    try std.testing.expect(isZigString([:5]u8));
}
test {
    try std.testing.expect(isZigString(*const [0]u8));
}
test {
    try std.testing.expect(isZigString(*[0]u8));
}
test {
    try std.testing.expect(isZigString(*const [0:0]u8));
}
test {
    try std.testing.expect(isZigString(*[0:0]u8));
}
test {
    try std.testing.expect(isZigString(*const [0:5]u8));
}
test {
    try std.testing.expect(isZigString(*[0:5]u8));
}
test {
    try std.testing.expect(isZigString(*const [10]u8));
}
test {
    try std.testing.expect(isZigString(*[10]u8));
}
test {
    try std.testing.expect(isZigString(*const [10:0]u8));
}
test {
    try std.testing.expect(isZigString(*[10:0]u8));
}
test {
    try std.testing.expect(isZigString(*const [10:5]u8));
}
test {
    try std.testing.expect(isZigString(*[10:5]u8));
}
test {
    try std.testing.expect(!isZigString(u8));
}
test {
    try std.testing.expect(!isZigString([4]u8));
}
test {
    try std.testing.expect(!isZigString([4:0]u8));
}
test {
    try std.testing.expect(!isZigString([*]const u8));
}
test {
    try std.testing.expect(!isZigString([*]const [4]u8));
}
test {
    try std.testing.expect(!isZigString([*c]const u8));
}
test {
    try std.testing.expect(!isZigString([*c]const [4]u8));
}
test {
    try std.testing.expect(!isZigString([*:0]const u8));
}
test {
    try std.testing.expect(!isZigString([*:0]const u8));
}
test {
    try std.testing.expect(!isZigString(*[]const u8));
}
test {
    try std.testing.expect(!isZigString(?[]const u8));
}
test {
    try std.testing.expect(!isZigString(?*const [4]u8));
}
test {
    try std.testing.expect(!isZigString([]allowzero u8));
}
test {
    try std.testing.expect(!isZigString([]volatile u8));
}
test {
    try std.testing.expect(!isZigString(*allowzero [4]u8));
}
test {
    try std.testing.expect(!isZigString(*volatile [4]u8));
}
