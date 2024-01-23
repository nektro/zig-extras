const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn isArrayOf(comptime T: type) std.meta.trait.TraitFn {
    const Closure = struct {
        pub fn trait(comptime C: type) bool {
            return switch (@typeInfo(C)) {
                .Array => |ti| ti.child == T,
                else => false,
            };
        }
    };
    return Closure.trait;
}
