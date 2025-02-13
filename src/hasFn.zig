const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

pub fn hasFn(comptime name: []const u8) fn (type) bool {
    const Closure = struct {
        pub fn trait(comptime T: type) bool {
            if (!comptime extras.isContainer(T)) return false;
            if (!comptime @hasDecl(T, name)) return false;
            const DeclType = @TypeOf(@field(T, name));
            return @typeInfo(DeclType) == .Fn;
        }
    };
    return Closure.trait;
}

test {
    const TestStruct = struct {
        pub fn useless() void {}
    };

    try std.testing.expect(hasFn("useless")(TestStruct));
    try std.testing.expect(!hasFn("append")(TestStruct));
    try std.testing.expect(!hasFn("useless")(u8));
}
