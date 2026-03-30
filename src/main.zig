const std = @import("std");
const log = std.log;
const Io = std.Io;
const process = std.process;
const zpng = @import("zpng");
const compress = std.compress;

pub fn main(init: process.Init) !void {
    const arena = init.arena.allocator();
    const io = init.io;

    var args = init.minimal.args.iterateAllocator(arena) catch |err| {
        return log.err("{}", .{err});
    };
    defer args.deinit();

    if (!args.skip()) {
        return log.err("{s}", .{"Invalid argument count"});
    }

    const file_name = args.next() orelse return error.MissingFileName;
    var file_handle: Io.File = Io.Dir.cwd().openFile(io, file_name, .{}) catch |err| {
        return log.err("{}", .{err});
    };
    defer file_handle.close(io);

    var file_reader_buffer: [1024]u8 = undefined;
    var file_reader: Io.File.Reader = .init(file_handle, io, &file_reader_buffer);
    const reader: *Io.Reader = &file_reader.interface;

    var parser = try zpng.Decode.Parser.init(init.gpa, reader);
    defer parser.deinit();

    var zstd_window_buffer = try arena.alloc(u8, compress.zstd.default_window_len);
    var zstd_reader_buffer = try arena.alloc(u8, compress.zstd.default_window_len);

    while (parser.next() catch null) |chunk| {}

    // var inflate = compress.zstd.Decompress.init(input: *Reader, buffer: []u8, options: Options)
}
