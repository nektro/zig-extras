const std = @import("std");
const string = []const u8;
const range = @import("range").range;

pub fn fmtByteCountIEC(alloc: std.mem.Allocator, b: u64) !string {
    return try reduceNumber(alloc, b, 1024, "B", "KMGTPEZY");
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
    return try std.fmt.allocPrint(alloc, "{d:.3} {s}{s}", .{ intToFloat(input) / intToFloat(div), prefixes[exp .. exp + 1], base });
}

pub fn intToFloat(n: u64) f64 {
    return @intToFloat(f64, n);
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

pub fn base64EncodeAlloc(alloc: std.mem.Allocator, input: string) !string {
    const base64 = std.base64.standard.Encoder;
    var buf = try alloc.alloc(u8, base64.calcSize(input.len));
    return base64.encode(buf, input);
}

pub fn asciiUpper(alloc: std.mem.Allocator, input: string) ![]u8 {
    var buf = try alloc.dupe(u8, input);
    for (range(buf.len)) |_, i| {
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
    for (slice) |item, i| {
        const shift = @intCast(std.math.Log2Int(T), b * (slice.len - 1 - i));
        n = n | (@as(T, item) << shift);
    }
    return n;
}

pub fn FieldType(comptime T: type, comptime field: std.meta.FieldEnum(T)) type {
    return std.meta.fieldInfo(T, field).field_type;
}

pub fn fileList(alloc: std.mem.Allocator, dir: std.fs.Dir) ![]string {
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

pub fn dirSize(alloc: std.mem.Allocator, dir: std.fs.Dir) !u64 {
    var res: u64 = 0;

    var walk = try dir.walk(alloc);
    defer walk.deinit();
    while (try walk.next()) |entry| {
        if (entry.kind != .File) continue;
        res += try fileSize(dir, entry.path);
    }
    return res;
}

pub fn fileSize(dir: std.fs.Dir, sub_path: string) !u64 {
    const f = try dir.openFile(sub_path, .{});
    defer f.close();
    const s = try f.stat();
    return s.size;
}

pub const HashFn = enum {
    blake3,
    gimli,
    md5,
    sha1,
    sha224,
    sha256,
    sha384,
    sha512,
    sha3_224,
    sha3_256,
    sha3_384,
    sha3_512,
};

pub fn hashFile(alloc: std.mem.Allocator, dir: std.fs.Dir, sub_path: string, comptime algo: HashFn) !string {
    const file = try dir.openFile(sub_path, .{});
    defer file.close();
    const hash = std.crypto.hash;
    const Algo = switch (algo) {
        .blake3 => hash.Blake3,
        .gimli => hash.Gimli,
        .md5 => hash.Md5,
        .sha1 => hash.Sha1,
        .sha224 => hash.sha2.Sha224,
        .sha256 => hash.sha2.Sha256,
        .sha384 => hash.sha2.Sha384,
        .sha512 => hash.sha2.Sha512,
        .sha3_224 => hash.sha3.Sha3_224,
        .sha3_256 => hash.sha3.Sha3_256,
        .sha3_384 => hash.sha3.Sha3_384,
        .sha3_512 => hash.sha3.Sha3_512,
    };
    var h = Algo.init(.{});
    var out: [Algo.digest_length]u8 = undefined;
    try pipe(file.reader(), h.writer());
    h.final(&out);

    var res: [Algo.digest_length * 2]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&res);
    try std.fmt.format(fbs.writer(), "{x}", .{std.fmt.fmtSliceHexLower(&out)});
    return try alloc.dupe(u8, &res);
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
    for (fields) |item, i| {
        types[i] = item.field_type;
    }
    return std.meta.Tuple(&types);
}

pub fn positionalInit(comptime T: type, args: FieldsTuple(T)) T {
    var t: T = undefined;
    inline for (std.meta.fields(T)) |field, i| {
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
