const std = @import("std");
const Io = std.Io;
const mem = std.mem;
const heap = std.heap;
const math = std.math;
const fmt = std.fmt;
const Parser = @This();
const Chunck = @import("Chunck.zig");

buffer: []u8,
index: usize,
chunck: ?Chunck,

pub const png_signature: []const u8 = "\x89\x50\x4E\x47\x0D\x0A\x1A\x0A";

pub fn init(buffer: []u8) Parser {
    return .{
        .buffer = buffer,
        .index = 0,
        .chunck = null,
    };
}

fn findSignature(self: *Parser) ?usize {
    return std.mem.find(u8, self.buffer, png_signature);
}

pub fn next(self: *Parser) ?Chunck {
    if (self.index >= self.buffer.len) {
        return null;
    } else if (self.chunck) |_| {
        self.getNextChunckSize() catch return null;
        self.getNextChunckType() catch return null;
        self.getNextChunckData() catch return null;
        self.getNextChunckCrc32() catch return null;
        return self.chunck;
    } else {
        defer self.index += png_signature.len;
        self.chunck = undefined;
        self.findSignature() orelse return null;
    }
}

fn getNextChunckSize(self: *Parser) !void {
    if (self.index + @sizeOf(u32) >= self.buffer.len) {
        return error.Eof;
    } else {
        defer self.index += @sizeOf(u32);
        self.current.size = mem.readInt(u32, self.buffer[self.index..][0..4], .big);
    }
}

fn getNextChunckType(self: *Parser) !void {
    if (self.index + @sizeOf(u32) >= self.buffer.len) {
        return error.Eof;
    } else {
        defer self.index += @sizeOf(u32);
        self.current.kind = mem.readInt(u32, self.buffer[self.index..][0..4], .big);
    }
}

fn getNextChunckData(self: *Parser) !void {
    if (self.index + self.current.size >= self.buffer.len) {
        return error.Eof;
    } else {
        defer self.index += self.current.size;
        self.current.data = self.buffer[self.index..][0..self.current.size];
    }
}

fn getNextChunckCrc32(self: *Parser) !void {
    if (self.index + @sizeOf(u32) >= self.buffer.len) {
        return error.Eof;
    } else {
        defer self.index += @sizeOf(u32);
        self.current.crc = mem.readInt(u32, self.buffer[self.index..][0..4], .big);
    }
}
