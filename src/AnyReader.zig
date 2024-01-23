const std = @import("std");
const string = []const u8;
const extras = @import("./lib.zig");
const assert = std.debug.assert;

pub const AnyReader = struct {
    readFn: *const fn (*anyopaque, []u8) anyerror!usize,
    state: *anyopaque,

    pub fn from(reader: anytype) AnyReader {
        const R = @TypeOf(reader);
        const ctx = reader.context;
        const Ctx = @TypeOf(ctx);
        switch (@typeInfo(Ctx)) {
            .Pointer => {
                const S = struct {
                    fn foo(s: *anyopaque, buffer: []u8) anyerror!usize {
                        const r = R{ .context = @ptrCast(@alignCast(s)) };
                        return r.read(buffer);
                    }
                };
                return .{
                    .readFn = S.foo,
                    .state = ctx,
                };
            },
            .Struct => switch (R) {
                std.fs.File.Reader => {
                    const S = struct {
                        fn foo(s: *anyopaque, buffer: []u8) anyerror!usize {
                            const r = R{ .context = .{ .handle = @intCast(@intFromPtr(s)) } };
                            return r.read(buffer);
                        }
                    };
                    return .{
                        .readFn = S.foo,
                        .state = @ptrFromInt(@as(usize, @intCast(ctx.handle))),
                    };
                },
                else => @compileError(@typeName(R)),
            },
            else => |v| @compileError(@typeName(R) ++ " , " ++ @tagName(v)),
        }
    }

    pub fn read(r: AnyReader, buffer: []u8) anyerror!usize {
        return r.readFn(r.state, buffer);
    }

    pub fn readByte(self: AnyReader) !u8 {
        var result: [1]u8 = undefined;
        const amt_read = try self.read(result[0..]);
        if (amt_read < 1) return error.EndOfStream;
        return result[0];
    }

    pub fn readInt(self: AnyReader, comptime T: type, endian: std.builtin.Endian) !T {
        const bytes = try self.readBytesNoEof(@as(u16, @intCast((@as(u17, @typeInfo(T).Int.bits) + 7) / 8)));
        return std.mem.readInt(T, &bytes, endian);
    }

    pub fn readBytesNoEof(self: AnyReader, comptime num_bytes: usize) ![num_bytes]u8 {
        var bytes: [num_bytes]u8 = undefined;
        try self.readNoEof(&bytes);
        return bytes;
    }

    pub fn readNoEof(self: AnyReader, buf: []u8) !void {
        const amt_read = try self.readAll(buf);
        if (amt_read < buf.len) return error.EndOfStream;
    }

    pub fn readAll(self: AnyReader, buffer: []u8) !usize {
        return self.readAtLeast(buffer, buffer.len);
    }

    pub fn readAtLeast(self: AnyReader, buffer: []u8, len: usize) !usize {
        assert(len <= buffer.len);
        var index: usize = 0;
        while (index < len) {
            const amt = try self.read(buffer[index..]);
            if (amt == 0) break;
            index += amt;
        }
        return index;
    }

    pub fn readAllAlloc(self: AnyReader, allocator: std.mem.Allocator, max_size: usize) ![]u8 {
        var array_list = std.ArrayList(u8).init(allocator);
        defer array_list.deinit();
        try self.readAllArrayList(&array_list, max_size);
        return try array_list.toOwnedSlice();
    }

    pub fn readAllArrayList(self: AnyReader, array_list: *std.ArrayList(u8), max_append_size: usize) !void {
        return self.readAllArrayListAligned(null, array_list, max_append_size);
    }

    pub fn readAllArrayListAligned(self: AnyReader, comptime alignment: ?u29, array_list: *std.ArrayListAligned(u8, alignment), max_append_size: usize) !void {
        try array_list.ensureTotalCapacity(@min(max_append_size, 4096));
        const original_len = array_list.items.len;
        var start_index: usize = original_len;
        while (true) {
            array_list.expandToCapacity();
            const dest_slice = array_list.items[start_index..];
            const bytes_read = try self.readAll(dest_slice);
            start_index += bytes_read;

            if (start_index - original_len > max_append_size) {
                array_list.shrinkAndFree(original_len + max_append_size);
                return error.StreamTooLong;
            }

            if (bytes_read != dest_slice.len) {
                array_list.shrinkAndFree(start_index);
                return;
            }

            // This will trigger ArrayList to expand superlinearly at whatever its growth rate is.
            try array_list.ensureTotalCapacity(start_index + 1);
        }
    }
};
