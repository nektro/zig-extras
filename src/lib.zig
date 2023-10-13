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
    return try std.fmt.allocPrint(alloc, "{d:.3} {s}{s}", .{ @as(f64, @floatFromInt(input)) / @as(f64, @floatFromInt(div)), prefixes[exp .. exp + 1], base });
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

pub fn trimPrefixEnsure(in: string, prefix: string) ?string {
    if (!std.mem.startsWith(u8, in, prefix)) return null;
    return in[prefix.len..];
}

pub fn trimSuffix(in: string, suffix: string) string {
    if (std.mem.endsWith(u8, in, suffix)) {
        return in[0 .. in.len - suffix.len];
    }
    return in;
}

pub fn trimSuffixEnsure(in: string, suffix: string) ?string {
    if (!std.mem.endsWith(u8, in, suffix)) return null;
    return in[0 .. in.len - suffix.len];
}

pub fn base64EncodeAlloc(alloc: std.mem.Allocator, input: string) !string {
    const base64 = std.base64.standard.Encoder;
    var buf = try alloc.alloc(u8, base64.calcSize(input.len));
    return base64.encode(buf, input);
}

pub fn base64DecodeAlloc(alloc: std.mem.Allocator, input: string) !string {
    const base64 = std.base64.standard.Decoder;
    var buf = try alloc.alloc(u8, try base64.calcSizeForSlice(input));
    try base64.decode(buf, input);
    return buf;
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
    if (s.kind != .directory) {
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
        const shift: std.math.Log2Int(T) = @intCast(b * (slice.len - 1 - i));
        n = n | (@as(T, item) << shift);
    }
    return n;
}

pub fn fileList(alloc: std.mem.Allocator, dir: std.fs.IterableDir) ![]string {
    var list = std.ArrayList(string).init(alloc);
    defer list.deinit();

    var walk = try dir.walk(alloc);
    defer walk.deinit();
    while (try walk.next()) |entry| {
        if (entry.kind != .file) continue;
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
    return @ptrCast(@alignCast(ptr));
}

pub fn ptrCastConst(comptime T: type, ptr: *const anyopaque) *const T {
    if (@alignOf(T) == 0) @compileError(@typeName(T));
    return @ptrCast(@alignCast(ptr));
}

pub fn sortBy(comptime T: type, items: []T, comptime field: std.meta.FieldEnum(T)) void {
    std.mem.sort(T, items, {}, struct {
        fn f(_: void, lhs: T, rhs: T) bool {
            return @field(lhs, @tagName(field)) < @field(rhs, @tagName(field));
        }
    }.f);
}

pub fn sortBySlice(comptime T: type, items: []T, comptime field: std.meta.FieldEnum(T)) void {
    std.mem.sort(T, items, {}, struct {
        fn f(_: void, lhs: T, rhs: T) bool {
            return lessThanSlice(std.meta.FieldType(T, field))({}, @field(lhs, @tagName(field)), @field(rhs, @tagName(field)));
        }
    }.f);
}

pub fn lessThanSlice(comptime T: type) fn (void, T, T) bool {
    return struct {
        fn f(_: void, lhs: T, rhs: T) bool {
            const result = for (0..@min(lhs.len, rhs.len)) |i| {
                if (lhs[i] < rhs[i]) break true;
                if (lhs[i] > rhs[i]) break false;
            } else false;
            return result;
        }
    }.f;
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
        try writer.writeByte(if (c == self.from) self.to else @intCast(c));
    }
}

pub fn randomBytes(comptime len: usize) [len]u8 {
    var bytes: [len]u8 = undefined;
    std.crypto.random.bytes(&bytes);
    return bytes;
}

pub fn writeEnumBig(writer: anytype, comptime E: type, value: E) !void {
    try writer.writeIntBig(@typeInfo(E).Enum.tag_type, @intFromEnum(value));
}

pub fn readEnumBig(reader: anytype, comptime E: type) !E {
    return @enumFromInt(try reader.readIntBig(@typeInfo(E).Enum.tag_type));
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
            const size = @min(dest.len, buf.len - self.pos);
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
    if (T == u8) return reader.readByte(); // single bytes dont have an endianness
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
                .Packed => return @bitCast(try readType(reader, t.backing_integer.?, endian)),
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
        .Enum => |t| @enumFromInt(try readType(reader, t.tag_type, endian)),
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
        return a + @as(@TypeOf(a), @intCast(b));
    }
    return a - @as(@TypeOf(a), @intCast(-@as(OneBiggerInt(@TypeOf(b)), b)));
}

/// Allows u32 + i16 to work
pub fn safeAddWrap(a: anytype, b: anytype) @TypeOf(a) {
    if (b >= 0) {
        return a +% @as(@TypeOf(a), @intCast(b));
    }
    return a -% @as(@TypeOf(a), @intCast(-@as(OneBiggerInt(@TypeOf(b)), b)));
}

pub fn readBytesAlloc(reader: anytype, alloc: std.mem.Allocator, len: usize) ![]u8 {
    var list = std.ArrayListUnmanaged(u8){};
    try list.ensureTotalCapacityPrecise(alloc, len);
    errdefer list.deinit(alloc);
    list.appendNTimesAssumeCapacity(0, len);
    try reader.readNoEof(list.items[0..len]);
    return list.items;
}

pub fn readFile(dir: std.fs.Dir, sub_path: string, alloc: std.mem.Allocator) !string {
    _ = dir;
    _ = sub_path;
    _ = alloc;
    @compileError("use std.fs.Dir.readFileAlloc instead");
}

pub fn nullifyS(s: ?string) ?string {
    if (s == null) return null;
    if (s.?.len == 0) return null;
    return s.?;
}

pub fn sliceTo(comptime T: type, haystack: []const T, needle: T) []const T {
    if (std.mem.indexOfScalar(T, haystack, needle)) |index| {
        return haystack[0..index];
    }
    return haystack;
}

pub fn matchesAll(comptime T: type, haystack: []const T, comptime needle: fn (T) bool) bool {
    for (haystack) |c| {
        if (!needle(c)) {
            return false;
        }
    }
    return true;
}

pub fn matchesAny(comptime T: type, haystack: []const T, comptime needle: fn (T) bool) bool {
    for (haystack) |c| {
        if (needle(c)) {
            return true;
        }
    }
    return false;
}

pub fn opslice(slice: anytype, index: usize) ?std.meta.Child(@TypeOf(slice)) {
    if (slice.len <= index) return null;
    return slice[index];
}

pub fn assertLog(ok: bool, comptime message: string, args: anytype) void {
    if (!ok) std.log.err("assertion failure: " ++ message, args);
    if (!ok) unreachable; // assertion failure
}

pub fn parse_json(alloc: std.mem.Allocator, input: string) !std.json.Parsed(std.json.Value) {
    return std.json.parseFromSlice(std.json.Value, alloc, input, .{});
}

pub fn isArrayOf(comptime T: type) std.meta.trait.TraitFn {
    const Closure = struct {
        pub fn trait(comptime C: type) bool {
            return switch (@typeInfo(C)) {
                .Array => |ti| ti.child == T,
                else => false,
            };
        }
    };
    return Closure.trait;
}

pub fn parse_int(comptime T: type, s: ?string, b: u8, d: T) T {
    if (s == null) return d;
    return std.fmt.parseInt(T, s.?, b) catch d;
}

pub fn parse_bool(s: ?string) bool {
    return parse_int(u1, s, 10, 0) > 0;
}

pub fn to_hex(array: anytype) [array.len * 2]u8 {
    var res: [array.len * 2]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&res);
    std.fmt.format(fbs.writer(), "{x}", .{std.fmt.fmtSliceHexLower(&array)}) catch unreachable;
    return res;
}

pub fn FieldUnion(comptime T: type) type {
    const infos = std.meta.fields(T);

    var fields: [infos.len]std.builtin.Type.UnionField = undefined;
    inline for (infos, 0..) |field, i| {
        fields[i] = .{
            .name = field.name,
            .type = field.type,
            .alignment = field.alignment,
        };
    }
    return @Type(std.builtin.Type{ .Union = .{
        .layout = .Auto,
        .tag_type = std.meta.FieldEnum(T),
        .fields = &fields,
        .decls = &.{},
    } });
}

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

pub fn Partial(comptime T: type) type {
    const fields_before = std.meta.fields(T);
    var fields_after: [fields_before.len]std.builtin.Type.StructField = undefined;
    inline for (fields_before, 0..) |item, i| {
        fields_after[i] = std.builtin.Type.StructField{
            .name = item.name,
            .type = ?item.type,
            .default_value = &@as(?item.type, null),
            .is_comptime = false,
            .alignment = @alignOf(?item.type),
        };
    }
    return @Type(@unionInit(std.builtin.Type, "Struct", .{
        .layout = .Auto,
        .backing_integer = null,
        .fields = &fields_after,
        .decls = &.{},
        .is_tuple = false,
    }));
}

pub fn coalescePartial(comptime T: type, into: T, from: Partial(T)) T {
    var temp = into;
    inline for (comptime std.meta.fieldNames(T)) |name| {
        if (@field(from, name)) |val| @field(temp, name) = val;
    }
    return temp;
}

pub fn joinPartial(comptime P: type, a: P, b: P) P {
    var temp = a;
    inline for (comptime std.meta.fieldNames(P)) |name| {
        if (@field(b, name)) |val| @field(temp, name) = val;
    }
    return temp;
}

pub fn OneBiggerInt(comptime T: type) type {
    var info = @typeInfo(T);
    info.Int.bits += 1;
    return @Type(info);
}

pub fn ReverseFields(comptime T: type) type {
    var info = @typeInfo(T).Struct;
    const len = info.fields.len;
    var fields: [len]std.builtin.Type.StructField = undefined;
    for (0..len) |i| {
        fields[i] = info.fields[len - 1 - i];
    }
    info.fields = &fields;
    return @Type(.{ .Struct = info });
}

pub fn stringToEnum(comptime E: type, str: ?string) ?E {
    return std.meta.stringToEnum(E, str orelse return null);
}

pub fn containsAggregate(comptime T: type, haystack: []const T, needle: T) bool {
    for (haystack) |item| {
        if (T.eql(item, needle)) {
            return true;
        }
    }
    return false;
}

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
