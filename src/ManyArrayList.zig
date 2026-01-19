const std = @import("std");
const extras = @import("./lib.zig");

pub fn ManyArrayList(T: type) type {
    return struct {
        allocator: std.mem.Allocator,
        list: std.ArrayListUnmanaged(T),
        lengths: std.ArrayListUnmanaged(usize),

        pub fn init(allocator: std.mem.Allocator) @This() {
            return .{
                .allocator = allocator,
                .list = .{},
                .lengths = .{},
            };
        }

        pub fn deinit(self: *@This()) void {
            self.list.deinit(self.allocator);
            self.lengths.deinit(self.allocator);
        }

        pub fn add(self: *@This()) !usize {
            const n = self.lengths.items.len;
            try self.lengths.append(self.allocator, 0);
            return n;
        }

        pub fn appendSlice(self: *@This(), n: usize, slice: []const T) !void {
            const real_n = extras.sum(usize, self.lengths.items[0 .. n + 1]);
            try self.list.insertSlice(self.allocator, real_n, slice);
            self.lengths.items[n] += slice.len;
        }

        pub fn items(self: *@This(), n: usize) []T {
            const real_n = extras.sum(usize, self.lengths.items[0..n]);
            const len = self.lengths.items[n];
            return self.list.items[real_n..][0..len];
        }

        pub fn set(self: *@This(), n: usize, slice: []const T) !void {
            const real_n = extras.sum(usize, self.lengths.items[0..n]);
            try self.list.replaceRange(self.allocator, real_n, self.lengths.items[n], slice);
            self.lengths.items[n] = slice.len;
        }

        pub fn clear(self: *@This(), n: usize) void {
            const real_n = extras.sum(usize, self.lengths.items[0..n]);
            self.list.replaceRangeAssumeCapacity(real_n, self.lengths.items[n], &.{});
            self.lengths.items[n] = 0;
        }

        /// Does not reset .lengths so that deinit can still clean it up
        pub fn toOwnedSlice(self: *@This()) ![]T {
            return self.list.toOwnedSlice(self.allocator);
        }

        pub fn swap(self: *@This(), a: usize, b: usize) void {
            std.debug.assert(a != b);
            if (a < b) return self.swapLR(a, b);
            if (a > b) return self.swapLR(b, a);
            unreachable;
        }
        fn swapLR(self: *@This(), a: usize, b: usize) void {
            extras.swapManyLR(
                u8,
                self.list.items,
                extras.sum(usize, self.lengths.items[0..a]),
                self.lengths.items[a],
                extras.sum(usize, self.lengths.items[0..b]),
                self.lengths.items[b],
            );
            std.mem.swap(
                usize,
                &self.lengths.items[a],
                &self.lengths.items[b],
            );
        }

        pub fn remove(self: *@This(), n: usize) void {
            const real_n = extras.sum(usize, self.lengths.items[0..n]);
            self.list.replaceRangeAssumeCapacity(real_n, self.lengths.items[n], &.{});
            _ = self.lengths.orderedRemove(n);
        }

        pub fn replace(self: *@This(), n: usize, o: usize, l: usize, slice: []const T) !void {
            std.debug.assert(o + l <= self.lengths.items[n]);
            const real_n = extras.sum(usize, self.lengths.items[0..n]);
            try self.list.replaceRange(self.allocator, real_n + o, l, slice);
            self.lengths.items[n] -= l;
            self.lengths.items[n] += slice.len;
        }

        pub fn insertAt(self: *@This(), n: usize, slice: []const T) !void {
            try self.lengths.ensureUnusedCapacity(self.allocator, 1);
            try self.list.ensureUnusedCapacity(self.allocator, slice.len);
            const real_n = extras.sum(usize, self.lengths.items[0..n]);
            self.lengths.insertAssumeCapacity(n, slice.len);
            self.list.insertSlice(self.allocator, real_n, slice) catch unreachable;
        }
    };
}
