const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn LoggingWriter(comptime T: type, comptime scope: @Type(.EnumLiteral)) type {
    return struct {
        child_stream: T,

        pub const Error = T.Error;
        pub const Writer = std.io.Writer(Self, Error, write);

        const Self = @This();

        pub fn init(child_stream: T) Self {
            return .{
                .child_stream = child_stream,
            };
        }

        pub fn writer(self: Self) Writer {
            return .{ .context = self };
        }

        fn write(self: Self, bytes: []const u8) Error!usize {
            std.log.scoped(scope).debug("{s}", .{bytes});
            return self.child_stream.write(bytes);
        }
    };
}
