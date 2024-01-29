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
        if (exp == prefixes.len - 1) break;
    }
    const input_f: f64 = @floatFromInt(input);
    const div_f: f64 = @floatFromInt(div);
    return try std.fmt.allocPrint(alloc, "{d:.3} {s}{s}", .{ input_f / div_f, prefixes[exp..][0..1], base });
}

test {
    const allocator = std.testing.allocator;
    const actual = try reduceNumber(allocator, 1, 60, "s", "mh");
    defer allocator.free(actual);
    try std.testing.expect(std.mem.eql(u8, actual, "1 s"));
}
test {
    const allocator = std.testing.allocator;
    const actual = try reduceNumber(allocator, 60, 60, "s", "mh");
    defer allocator.free(actual);
    try std.testing.expect(std.mem.eql(u8, actual, "1.000 ms"));
}
test {
    const allocator = std.testing.allocator;
    const actual = try reduceNumber(allocator, 3600, 60, "s", "mh");
    defer allocator.free(actual);
    try std.testing.expect(std.mem.eql(u8, actual, "1.000 hs"));
}
test {
    const allocator = std.testing.allocator;
    const actual = try reduceNumber(allocator, 216000, 60, "s", "mh");
    defer allocator.free(actual);
    try std.testing.expect(std.mem.eql(u8, actual, "60.000 hs"));
}
