const std = @import("std");
const Io = std.Io;
const mem = std.mem;
const heap = std.heap;
const math = std.math;
const fmt = std.fmt;
const Parser = @This();

reader: *Io.Reader,
arena: heap.ArenaAllocator,

pub const signature: []const u8 = "\x89\x50\x4E\x47\x0D\x0A\x1A\x0A";

pub const Chunk = struct {
    size: u32 = undefined,
    kind: u32 = undefined,
    data: []const u8 = undefined,
    crc: u32 = undefined,

    pub fn format(
        self: @This(),
        writer: *std.Io.Writer,
    ) std.Io.Writer.Error!void {
        try writer.print("[size : {d} | kind : {s} | crc : {d:12}]\n", .{
            self.size,
            std.mem.asBytes(&self.kind),
            self.crc,
        });
    }
};

pub fn init(allocator: mem.Allocator, reader: *Io.Reader) !Parser {
    const maybe_signature = try reader.peek(signature.len);

    if (mem.startsWith(u8, signature, maybe_signature) == false) {
        return error.InvalidPngFormat;
    } else {
        reader.toss(signature.len);
    }

    return .{
        .reader = reader,
        .arena = .init(allocator),
    };
}

pub fn deinit(self: *Parser) void {
    defer self.* = undefined;
    self.arena.deinit();
}

pub fn next(self: *Parser) !Chunk {
    _ = self.arena.reset(.retain_capacity);

    const size = try self.reader.takeInt(u32, .big);
    const kind = try self.reader.peekInt(u32, .big);
    const data = try self.reader.readAlloc(self.arena.allocator(), @sizeOf(u32) + size);
    const crc = try self.reader.takeInt(u32, .big);
    const check = std.hash.Crc32.hash(data);

    if (check != crc) {
        return error.BadCrc32;
    }

    return Chunk{
        .size = size,
        .kind = kind,
        .data = data[@sizeOf(u32)..],
        .crc = crc,
    };
}

test "init - success" {
    const buffer = signature;
    var fixed_reader: Io.Reader = .fixed(buffer);
    const allocator = std.testing.allocator_instance.allocator();
    _ = try Parser.init(allocator, &fixed_reader);
}

test "init - error" {
    const buffer = signature[0..7];
    var fixed_reader: Io.Reader = .fixed(buffer);
    const allocator = std.testing.allocator_instance.allocator();
    try std.testing.expectError(error.InvalidPngFormat, Parser.init(allocator, &fixed_reader));
}
