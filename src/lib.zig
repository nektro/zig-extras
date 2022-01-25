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

pub fn dirSize(alloc: std.mem.Allocator, dir: std.fs.Dir) !usize {
    var res: usize = 0;

    var walk = try dir.walk(alloc);
    defer walk.deinit();
    while (try walk.next()) |entry| {
        if (entry.kind != .File) continue;
        res += try fileSize(dir, entry.path);
    }
    return res;
}

pub fn fileSize(dir: std.fs.Dir, sub_path: string) !usize {
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
    const h = &Algo.init(.{});
    var out: [Algo.digest_length]u8 = undefined;
    var hw = HashWriter(Algo){ .h = h };
    try pipe(file.reader(), hw.writer());
    h.final(&out);

    var res: [Algo.digest_length * 2]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&res);
    try std.fmt.format(fbs.writer(), "{x}", .{std.fmt.fmtSliceHexLower(&out)});
    return try alloc.dupe(u8, &res);
}

fn HashWriter(comptime T: type) type {
    return struct {
        h: *T,

        const Self = @This();
        pub const Error = error{};
        pub const Writer = std.io.Writer(*Self, Error, write);

        fn write(self: *Self, bytes: []const u8) Error!usize {
            self.h.update(bytes);
            return bytes.len;
        }

        pub fn writer(self: *Self) Writer {
            return .{ .context = self };
        }
    };
}

pub fn pipe(reader_from: anytype, writer_to: anytype) !void {
    var buf: [std.mem.page_size]u8 = undefined;
    var fifo = std.fifo.LinearFifo(u8, .Slice).init(&buf);
    defer fifo.deinit();
    try fifo.pump(reader_from, writer_to);
}
