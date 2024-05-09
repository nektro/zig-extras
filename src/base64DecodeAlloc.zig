const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn base64DecodeAlloc(alloc: std.mem.Allocator, input: string) !string {
    const base64 = std.base64.standard.Decoder;
    const buf = try alloc.alloc(u8, try base64.calcSizeForSlice(input));
    try base64.decode(buf, input);
    return buf;
}

test {
    std.testing.refAllDecls(@This());
}
