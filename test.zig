const std = @import("std");
const extras = @import("extras");

test {
    std.testing.refAllDeclsRecursive(extras);
}
