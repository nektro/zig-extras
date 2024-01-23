const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn LoggingReader(comptime T: type, comptime scope: @Type(.EnumLiteral)) type {
    return struct {
        child_stream: T,

        pub const Error = T.Error;
        pub const Reader = std.io.Reader(Self, Error, read);

        const Self = @This();

        pub fn init(child_stream: T) Self {
            return .{
                .child_stream = child_stream,
            };
        }

        pub fn reader(self: Self) Reader {
            return .{ .context = self };
        }

        fn read(self: Self, dest: []u8) Error!usize {
            const n = try self.child_stream.read(dest);
            std.log.scoped(scope).debug("{s}", .{dest[0..n]});
            return n;
        }
    };
}
