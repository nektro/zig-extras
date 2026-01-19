const std = @import("std");
const extras = @import("./lib.zig");

pub fn compareFnRange(N: type, H: type, lower: std.meta.FieldEnum(H), upper: std.meta.FieldEnum(H)) fn (N, H) std.math.Order {
    const S = struct {
        pub fn compare(needle: N, row: H) std.math.Order {
            if (needle < @field(row, @tagName(lower))) return .lt;
            if (needle > @field(row, @tagName(upper))) return .gt;
            return .eq;
        }
    };
    return S.compare;
}
