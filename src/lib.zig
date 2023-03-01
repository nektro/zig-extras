const std = @import("std");
const string = []const u8;
const assert = std.debug.assert;

pub fn fmtByteCountIEC(alloc: std.mem.Allocator, b: u64) !string {
    return try reduceNumber(alloc, b, 1024, "B", "KMGTPEZYRQ");
}

pub fn reduceNumber(alloc: std.mem.Allocator, input: u64, comptime unit: u64, comptime base: string, comptime prefixes: string) !string {
    if (input < unit) {
        return std.fmt.allocPrint(alloc, "{d} {s}", .{ input, base });
    }
    var div = unit;
    var exp: usize = 0;
    var n = input / unit;
    while (n >= unit) : (n /= unit) {
        div *= unit;
        exp += 1;
    }
    return try std.fmt.allocPrint(alloc, "{d:.3} {s}{s}", .{ @intToFloat(f64, input) / @intToFloat(f64, div), prefixes[exp .. exp + 1], base });
}

pub fn addSentinel(alloc: std.mem.Allocator, comptime T: type, input: []const T, comptime sentinel: T) ![:sentinel]const T {
    var list = try std.ArrayList(T).initCapacity(alloc, input.len + 1);
    try list.appendSlice(input);
    try list.append(sentinel);
    const str = list.toOwnedSlice();
    return str[0 .. str.len - 1 :sentinel];
}

const alphabet = "0123456789abcdefghijklmnopqrstuvwxyz";

pub fn randomSlice(alloc: std.mem.Allocator, rand: std.rand.Random, comptime T: type, len: usize) ![]T {
    var buf = try alloc.alloc(T, len);
    var i: usize = 0;
    while (i < len) : (i += 1) {
        buf[i] = alphabet[rand.int(u8) % alphabet.len];
    }
    return buf;
}

pub fn trimPrefix(in: string, prefix: string) string {
    if (std.mem.startsWith(u8, in, prefix)) {
        return in[prefix.len..];
    }
    return in;
}

pub fn trimSuffix(in: string, suffix: string) string {
    if (std.mem.endsWith(u8, in, suffix)) {
        return in[0 .. in.len - suffix.len];
    }
    return in;
}

pub fn base64EncodeAlloc(alloc: std.mem.Allocator, input: string) !string {
    const base64 = std.base64.standard.Encoder;
    var buf = try alloc.alloc(u8, base64.calcSize(input.len));
    return base64.encode(buf, input);
}

pub fn asciiUpper(alloc: std.mem.Allocator, input: string) ![]u8 {
    var buf = try alloc.dupe(u8, input);
    for (0..buf.len) |i| {
        buf[i] = std.ascii.toUpper(buf[i]);
    }
    return buf;
}

pub fn doesFolderExist(dir: ?std.fs.Dir, fpath: []const u8) !bool {
    const file = (dir orelse std.fs.cwd()).openFile(fpath, .{}) catch |e| switch (e) {
        error.FileNotFound => return false,
        error.IsDir => return true,
        else => return e,
    };
    defer file.close();
    const s = try file.stat();
    if (s.kind != .Directory) {
        return false;
    }
    return true;
}

pub fn doesFileExist(dir: ?std.fs.Dir, fpath: []const u8) !bool {
    const file = (dir orelse std.fs.cwd()).openFile(fpath, .{}) catch |e| switch (e) {
        error.FileNotFound => return false,
        error.IsDir => return true,
        else => return e,
    };
    defer file.close();
    return true;
}

pub fn sliceToInt(comptime T: type, comptime E: type, slice: []const E) !T {
    const a = @typeInfo(T).Int.bits;
    const b = @typeInfo(E).Int.bits;
    if (a < b * slice.len) return error.Overflow;

    var n: T = 0;
    for (slice, 0..) |item, i| {
        const shift = @intCast(std.math.Log2Int(T), b * (slice.len - 1 - i));
        n = n | (@as(T, item) << shift);
    }
    return n;
}

pub fn FieldType(comptime T: type, comptime field: std.meta.FieldEnum(T)) type {
    return std.meta.fieldInfo(T, field).type;
}

pub fn fileList(alloc: std.mem.Allocator, dir: std.fs.IterableDir) ![]string {
    var list = std.ArrayList(string).init(alloc);
    defer list.deinit();

    var walk = try dir.walk(alloc);
    defer walk.deinit();
    while (try walk.next()) |entry| {
        if (entry.kind != .File) continue;
        try list.append(try alloc.dupe(u8, entry.path));
    }
    return list.toOwnedSlice();
}

pub fn dirSize(alloc: std.mem.Allocator, dir: std.fs.IterableDir) !u64 {
    var res: u64 = 0;

    var walk = try dir.walk(alloc);
    defer walk.deinit();
    while (try walk.next()) |entry| {
        if (entry.kind != .File) continue;
        res += try fileSize(dir.dir, entry.path);
    }
    return res;
}

pub fn fileSize(dir: std.fs.Dir, sub_path: string) !u64 {
    const f = try dir.openFile(sub_path, .{});
    defer f.close();
    const s = try f.stat();
    return s.size;
}

pub fn hashFile(dir: std.fs.Dir, sub_path: string, comptime Algo: type) ![Algo.digest_length * 2]u8 {
    const file = try dir.openFile(sub_path, .{});
    defer file.close();
    var h = Algo.init(.{});
    var out: [Algo.digest_length]u8 = undefined;
    try pipe(file.reader(), h.writer());
    h.final(&out);
    var res: [Algo.digest_length * 2]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&res);
    try std.fmt.format(fbs.writer(), "{x}", .{std.fmt.fmtSliceHexLower(&out)});
    return res;
}

pub fn pipe(reader_from: anytype, writer_to: anytype) !void {
    var buf: [std.mem.page_size]u8 = undefined;
    var fifo = std.fifo.LinearFifo(u8, .Slice).init(&buf);
    defer fifo.deinit();
    try fifo.pump(reader_from, writer_to);
}

pub fn StringerJsonStringifyMixin(comptime S: type) type {
    return struct {
        pub fn jsonStringify(self: S, options: std.json.StringifyOptions, out_stream: anytype) !void {
            var buf: [1024]u8 = undefined;
            var fba = std.heap.FixedBufferAllocator.init(&buf);
            const alloc = fba.allocator();
            var list = std.ArrayList(u8).init(alloc);
            errdefer list.deinit();
            const writer = list.writer();
            try writer.writeAll(try self.toString(alloc));
            try std.json.stringify(list.toOwnedSlice(), options, out_stream);
        }
    };
}

pub fn TagNameJsonStringifyMixin(comptime S: type) type {
    return struct {
        pub fn jsonStringify(self: S, options: std.json.StringifyOptions, out_stream: anytype) !void {
            try std.json.stringify(@tagName(self), options, out_stream);
        }
    };
}

pub fn countScalar(comptime T: type, haystack: []const T, needle: T) usize {
    var found: usize = 0;

    for (haystack) |item| {
        if (item == needle) {
            found += 1;
        }
    }
    return found;
}

pub fn ptrCast(comptime T: type, ptr: *anyopaque) *T {
    if (@alignOf(T) == 0) @compileError(@typeName(T));
    return @ptrCast(*T, @alignCast(@alignOf(T), ptr));
}

pub fn ptrCastConst(comptime T: type, ptr: *const anyopaque) *const T {
    if (@alignOf(T) == 0) @compileError(@typeName(T));
    return @ptrCast(*const T, @alignCast(@alignOf(T), ptr));
}

pub fn sortBy(comptime T: type, items: []T, comptime field: std.meta.FieldEnum(T)) void {
    std.sort.sort(T, items, {}, struct {
        fn f(_: void, lhs: T, rhs: T) bool {
            return @field(lhs, @tagName(field)) < @field(rhs, @tagName(field));
        }
    }.f);
}

pub fn containsString(haystack: []const string, needle: string) bool {
    for (haystack) |item| {
        if (std.mem.eql(u8, item, needle)) {
            return true;
        }
    }
    return false;
}

pub fn FieldsTuple(comptime T: type) type {
    const fields = std.meta.fields(T);
    var types: [fields.len]type = undefined;
    for (fields, 0..) |item, i| {
        types[i] = item.type;
    }
    return std.meta.Tuple(&types);
}

pub fn positionalInit(comptime T: type, args: FieldsTuple(T)) T {
    var t: T = undefined;
    inline for (std.meta.fields(T), 0..) |field, i| {
        @field(t, field.name) = args[i];
    }
    return t;
}

pub fn d2index(d1len: usize, d1: usize, d2: usize) usize {
    return (d1len * d2) + d1;
}

pub fn ensureFieldSubset(comptime L: type, comptime R: type) void {
    for (std.meta.fields(L)) |item| {
        if (!@hasField(R, item.name)) @compileError(std.fmt.comptimePrint("{s} is missing the {s} field from {s}", .{ R, item.name, L }));
    }
}

pub fn fmtReplacer(bytes: string, from: u8, to: u8) std.fmt.Formatter(formatReplacer) {
    return .{ .data = .{ .bytes = bytes, .from = from, .to = to } };
}

const ReplacerData = struct { bytes: string, from: u8, to: u8 };
fn formatReplacer(self: ReplacerData, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
    _ = fmt;
    _ = options;
    for (self.bytes) |c| {
        try writer.writeByte(if (c == self.from) self.to else @intCast(u8, c));
    }
}

pub fn randomBytes(comptime len: usize) [len]u8 {
    var bytes: [len]u8 = undefined;
    std.crypto.random.bytes(&bytes);
    return bytes;
}

pub fn writeEnumBig(writer: anytype, comptime E: type, value: E) !void {
    try writer.writeIntBig(@typeInfo(E).Enum.tag_type, @enumToInt(value));
}

pub fn readEnumBig(reader: anytype, comptime E: type) !E {
    return @intToEnum(E, try reader.readIntBig(@typeInfo(E).Enum.tag_type));
}

pub fn readExpected(reader: anytype, expected: []const u8) !bool {
    for (expected) |item| {
        const actual = try reader.readByte();
        if (actual != item) {
            return false;
        }
    }
    return true;
}

pub fn readBytes(reader: anytype, comptime len: usize) ![len]u8 {
    var bytes: [len]u8 = undefined;
    assert(try reader.readAll(&bytes) == len);
    return bytes;
}

pub fn FixedMaxBuffer(comptime max_len: usize) type {
    return struct {
        buf: [max_len]u8,
        len: usize,
        pos: usize,

        const Self = @This();
        pub const Reader = std.io.Reader(*Self, error{}, read);

        pub fn init(r: anytype, runtime_len: usize) !Self {
            var fmr = Self{
                .buf = undefined,
                .len = runtime_len,
                .pos = 0,
            };
            _ = try r.readAll(fmr.buf[0..runtime_len]);
            return fmr;
        }

        pub fn reader(self: *Self) Reader {
            return .{ .context = self };
        }

        fn read(self: *Self, dest: []u8) error{}!usize {
            const buf = self.buf[0..self.len];
            const size = std.math.min(dest.len, buf.len - self.pos);
            const end = self.pos + size;
            std.mem.copy(u8, dest[0..size], buf[self.pos..end]);
            self.pos = end;
            return size;
        }

        pub fn readLen(self: *Self, len: usize) []const u8 {
            assert(self.pos + len <= self.len);
            defer self.pos += len;
            return self.buf[self.pos..][0..len];
        }

        pub fn atEnd(self: *const Self) bool {
            return self.pos == self.len;
        }
    };
}

pub fn hashBytes(comptime Algo: type, bytes: []const u8) [Algo.digest_length]u8 {
    var h = Algo.init(.{});
    var out: [Algo.digest_length]u8 = undefined;
    h.update(bytes);
    h.final(&out);
    return out;
}

pub fn readType(reader: anytype, comptime T: type, endian: std.builtin.Endian) !T {
    return switch (@typeInfo(T)) {
        .Struct => |t| {
            switch (t.layout) {
                .Auto, .Extern => {
                    var s: T = undefined;
                    inline for (std.meta.fields(T)) |field| {
                        @field(s, field.name) = try readType(reader, field.type, endian);
                    }
                    return s;
                },
                .Packed => return @bitCast(T, try readType(reader, t.backing_integer.?, endian)),
            }
        },
        .Array => |t| {
            var s: T = undefined;
            for (0..t.len) |i| {
                s[i] = try readType(reader, t.child, endian);
            }
            return s;
        },
        .Int => try reader.readInt(T, endian),
        .Enum => |t| @intToEnum(T, try readType(reader, t.tag_type, endian)),
        else => |e| @compileError(@tagName(e)),
    };
}

pub fn indexBufferT(bytes: [*]const u8, comptime T: type, endian: std.builtin.Endian, idx: usize, max_len: usize) T {
    std.debug.assert(idx < max_len);
    var fbs = std.io.fixedBufferStream((bytes + (idx * @sizeOf(T)))[0..@sizeOf(T)]);
    return readType(fbs.reader(), T, endian) catch |err| switch (err) {
        error.EndOfStream => unreachable, // assert above has been violated
    };
}

pub fn BufIndexer(comptime T: type, comptime endian: std.builtin.Endian) type {
    return struct {
        bytes: [*]const u8,
        max_len: usize,

        const Self = @This();

        pub fn init(bytes: [*]const u8, max_len: usize) Self {
            return .{
                .bytes = bytes,
                .max_len = max_len,
            };
        }

        pub fn at(self: *const Self, idx: usize) T {
            return indexBufferT(self.bytes, T, endian, idx, self.max_len);
        }
    };
}

pub fn skipToBoundary(pos: u64, boundary: u64, reader: anytype) !void {
    // const gdiff = counter.bytes_read % 4;
    // for (range(if (gdiff > 0) 4 - gdiff else 0)) |_| {
    const a = pos;
    const b = boundary;
    try reader.skipBytes(((a + (b - 1)) & ~(b - 1)) - a, .{});
}

/// ?A == A fails
/// ?A == @as(?A, b) works
pub fn is(a: anytype, b: @TypeOf(a)) bool {
    return a == b;
}

/// Allows u32 + i16 to work
pub fn safeAdd(a: anytype, b: anytype) @TypeOf(a) {
    if (b >= 0) {
        return a + @intCast(@TypeOf(a), b);
    }
    return a - @intCast(@TypeOf(a), -b);
}
