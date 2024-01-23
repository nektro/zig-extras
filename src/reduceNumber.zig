const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn reduceNumber(alloc: std.mem.Allocator, input: u64, comptime unit: u64, comptime base: string, comptime prefixes: string) !string {
    if (input < unit) {
        return std.fmt.allocPrint(alloc, "{d} {s}", .{ input, base });
    }
    var div = unit;
    var exp: usize = 0;
    var n = input / unit;
    while (n >= unit) : (n /= unit) {
        div *= unit;
        exp += 1;
    }
    return try std.fmt.allocPrint(alloc, "{d:.3} {s}{s}", .{ @as(f64, @floatFromInt(input)) / @as(f64, @floatFromInt(div)), prefixes[exp .. exp + 1], base });
}
