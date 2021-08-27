const std = @import("std");
const string = []const u8;

pub fn fmtByteCountIEC(alloc: *std.mem.Allocator, b: u64) !string {
    return try reduceNumber(alloc, b, 1024, "B", "KMGTPEZY");
}

pub fn reduceNumber(alloc: *std.mem.Allocator, input: u64, comptime unit: u64, comptime base: string, comptime prefixes: string) !string {
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
    return try std.fmt.allocPrint(alloc, "{d:.3} {s}{s}", .{ intToFloat(input) / intToFloat(div), prefixes[exp .. exp + 1], base });
}

pub fn intToFloat(n: u64) f64 {
    return @intToFloat(f64, n);
}