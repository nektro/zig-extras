const std = @import("std");
const extras = @import("./lib.zig");

pub fn compareFnField(N: type, H: type, f: std.meta.FieldEnum(H)) fn (N, H) std.math.Order {
    const S = struct {
        pub fn compare(needle: N, row: H) std.math.Order {
            if (needle < @field(row, @tagName(f))) return .lt;
            if (needle > @field(row, @tagName(f))) return .gt;
            return .eq;
        }
    };
    return S.compare;
}
