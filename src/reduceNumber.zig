const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn reduceNumber(writer: anytype, input: u64, comptime unit: u64, comptime base: string, comptime prefixes: string) !void {
    if (input < unit) {
        return try writer.print("{d} {s}", .{ input, base });
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
    return try writer.print("{d:.3} {s}{s}", .{ input_f / div_f, prefixes[exp..][0..1], base });
}

test {
    const allocator = std.testing.allocator;
    var list = std.ArrayList(u8).init(allocator);
    defer list.deinit();
    try reduceNumber(list.writer(), 1, 60, "s", "mh");
    try std.testing.expect(std.mem.eql(u8, list.items, "1 s"));
}
test {
    const allocator = std.testing.allocator;
    var list = std.ArrayList(u8).init(allocator);
    defer list.deinit();
    try reduceNumber(list.writer(), 60, 60, "s", "mh");
    try std.testing.expect(std.mem.eql(u8, list.items, "1.000 ms"));
}
test {
    const allocator = std.testing.allocator;
    var list = std.ArrayList(u8).init(allocator);
    defer list.deinit();
    try reduceNumber(list.writer(), 3600, 60, "s", "mh");
    try std.testing.expect(std.mem.eql(u8, list.items, "1.000 hs"));
}
test {
    const allocator = std.testing.allocator;
    var list = std.ArrayList(u8).init(allocator);
    defer list.deinit();
    try reduceNumber(list.writer(), 216000, 60, "s", "mh");
    try std.testing.expect(std.mem.eql(u8, list.items, "60.000 hs"));
}
