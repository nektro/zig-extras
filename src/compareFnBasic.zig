const std = @import("std");
const extras = @import("./lib.zig");

pub fn compareFnBasic(N: type) fn (N, N) std.math.Order {
    const S = struct {
        pub fn compare(a: N, b: N) std.math.Order {
            if (a < b) return .lt;
            if (a > b) return .gt;
            return .eq;
        }
    };
    return S.compare;
}
