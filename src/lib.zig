const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");
const assert = std.debug.assert;
const builtin = @import("builtin");

pub usingnamespace @import("./reduceNumber.zig");
pub usingnamespace @import("./fmtByteCountIEC.zig");
pub usingnamespace @import("./randomSlice.zig");
pub usingnamespace @import("./trimPrefix.zig");
pub usingnamespace @import("./trimPrefixEnsure.zig");
pub usingnamespace @import("./trimSuffix.zig");
pub usingnamespace @import("./trimSuffixEnsure.zig");
pub usingnamespace @import("./base64EncodeAlloc.zig");
pub usingnamespace @import("./base64DecodeAlloc.zig");
pub usingnamespace @import("./asciiUpper.zig");
pub usingnamespace @import("./doesFileExist.zig");
pub usingnamespace @import("./doesFolderExist.zig");
pub usingnamespace @import("./sliceToInt.zig");
pub usingnamespace @import("./fileList.zig");
pub usingnamespace @import("./fileSize.zig");
pub usingnamespace @import("./dirSize.zig");
pub usingnamespace @import("./hashFile.zig");
pub usingnamespace @import("./pipe.zig");
pub usingnamespace @import("./StringerJsonStringifyMixin.zig");
pub usingnamespace @import("./TagNameJsonStringifyMixin.zig");
pub usingnamespace @import("./countScalar.zig");
pub usingnamespace @import("./sortBy.zig");
pub usingnamespace @import("./sortBySlice.zig");
pub usingnamespace @import("./lessThanSlice.zig");
pub usingnamespace @import("./containsString.zig");
pub usingnamespace @import("./ensureFieldSubset.zig");
pub usingnamespace @import("./fmtReplacer.zig");
pub usingnamespace @import("./randomBytes.zig");
pub usingnamespace @import("./readExpected.zig");
pub usingnamespace @import("./readBytes.zig");
pub usingnamespace @import("./FixedMaxBuffer.zig");
pub usingnamespace @import("./hashBytes.zig");
pub usingnamespace @import("./readType.zig");
pub usingnamespace @import("./indexBufferT.zig");
pub usingnamespace @import("./BufIndexer.zig");
pub usingnamespace @import("./skipToBoundary.zig");
pub usingnamespace @import("./is.zig");
pub usingnamespace @import("./safeAdd.zig");
pub usingnamespace @import("./safeAddWrap.zig");
pub usingnamespace @import("./readBytesAlloc.zig");
pub usingnamespace @import("./nullifyS.zig");
pub usingnamespace @import("./sliceTo.zig");
pub usingnamespace @import("./matchesAll.zig");
pub usingnamespace @import("./matchesAny.zig");
pub usingnamespace @import("./opslice.zig");

pub fn assertLog(ok: bool, comptime message: string, args: anytype) void {
    if (!ok) std.log.err("assertion failure: " ++ message, args);
    if (!ok) unreachable; // assertion failure
}

pub usingnamespace @import("./parse_json.zig");
pub usingnamespace @import("./isArrayOf.zig");
pub usingnamespace @import("./parse_int.zig");
pub usingnamespace @import("./parse_bool.zig");
pub usingnamespace @import("./to_hex.zig");
pub usingnamespace @import("./FieldUnion.zig");
pub usingnamespace @import("./LoggingReader.zig");
pub usingnamespace @import("./LoggingWriter.zig");
pub usingnamespace @import("./Partial.zig");
pub usingnamespace @import("./coalescePartial.zig");
pub usingnamespace @import("./joinPartial.zig");
pub usingnamespace @import("./OneBiggerInt.zig");
pub usingnamespace @import("./ReverseFields.zig");
pub usingnamespace @import("./stringToEnum.zig");
pub usingnamespace @import("./containsAggregate.zig");
pub usingnamespace @import("./AnyReader.zig");
pub usingnamespace @import("./sum.zig");
pub usingnamespace @import("./RingBuffer.zig");

pub fn fd_realpath(fd: std.posix.fd_t) ![std.fs.max_path_bytes:0]u8 {
    switch (builtin.os.tag) {
        .linux => {
            var buf = std.mem.zeroes([64]u8);
            var res = std.mem.zeroes([std.fs.max_path_bytes:0]u8);
            const str = try std.fmt.bufPrint(&buf, "/proc/self/fd/{d}", .{fd});
            _ = try std.posix.readlink(str, &res);
            return res;
        },
        else => @compileError("not implemented!"),
    }
}
test {
    if (builtin.os.tag != .linux) return;
    _ = &fd_realpath;
}

pub usingnamespace @import("./rawInt.zig");
pub usingnamespace @import("./expectSimilarType.zig");
pub usingnamespace @import("./rawIntBytes.zig");
pub usingnamespace @import("./globalOption.zig");
pub usingnamespace @import("./OneSmallerInt.zig");
pub usingnamespace @import("./FlippedInt.zig");
pub usingnamespace @import("./isZigString.zig");
pub usingnamespace @import("./isIndexable.zig");
pub usingnamespace @import("./isSlice.zig");
pub usingnamespace @import("./matchesNone.zig");
pub usingnamespace @import("./indexOfSlice.zig");
pub usingnamespace @import("./mapBy.zig");
pub usingnamespace @import("./lessThanBy.zig");
pub usingnamespace @import("./isContainer.zig");
pub usingnamespace @import("./hasFn.zig");
pub usingnamespace @import("./hasFields.zig");
pub usingnamespace @import("./StructOfSlices.zig");
pub usingnamespace @import("./StructOfArrays.zig");
pub usingnamespace @import("./StaticMultiList.zig");
pub usingnamespace @import("./join.zig");
pub usingnamespace @import("./omit.zig");
pub usingnamespace @import("./swapMany.zig");
pub usingnamespace @import("./ManyArrayList.zig");
