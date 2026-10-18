const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");

/// Asserts at comptime that L ⊆ R.
pub fn ensureFieldSubset(comptime L: type, comptime R: type) void {
    for (comptime std.meta.fieldNames(L)) |item| {
        if (!@hasField(R, item)) {
            @compileError(std.fmt.comptimePrint("'{s}' field in {s} is not present in {s}", .{ item, @typeName(L), @typeName(R) }));
        }
    }
}

test {
    comptime {
        ensureFieldSubset(enum {
            linux,
            macos,
            windows,
            freebsd,
        }, std.Target.Os.Tag);
    }
}
