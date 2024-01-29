const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn base64EncodeAlloc(alloc: std.mem.Allocator, input: string) !string {
    const base64 = std.base64.standard.Encoder;
    var buf = try alloc.alloc(u8, base64.calcSize(input.len));
    return base64.encode(buf, input);
}

test {
    std.testing.refAllDecls(@This());
}
