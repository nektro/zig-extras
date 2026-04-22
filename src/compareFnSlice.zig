const std = @import("std");
const extras = @import("./lib.zig");

// Remove after updating to Zig 0.17. Ref: https://codeberg.org/ziglang/zig/pulls/32010
pub fn compareFnSlice(comptime T: type) fn ([]const T, []const T) std.math.Order {
    const S = struct {
        fn order(lhs: []const T, rhs: []const T) std.math.Order {
            if (lhs.ptr != rhs.ptr) {
                const n = @min(lhs.len, rhs.len);
                for (lhs[0..n], rhs[0..n]) |lhs_elem, rhs_elem| {
                    switch (std.math.order(lhs_elem, rhs_elem)) {
                        .eq => continue,
                        .lt => return .lt,
                        .gt => return .gt,
                    }
                }
            }
            return std.math.order(lhs.len, rhs.len);
        }
    };
    return S.order;
}
