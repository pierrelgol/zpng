const std = @import("std");
const mem = std.mem;
const Chunck = @This();
const hash = std.hash;

pub const IHDR = kindFromBytes("IHDR");
pub const PLTE = kindFromBytes("PLTE");
pub const IDAT = kindFromBytes("IDAT");
pub const IEND = kindFromBytes("IEND");
pub const tRNS = kindFromBytes("tRNS");
pub const gAMA = kindFromBytes("gAMA");
pub const cHRM = kindFromBytes("cHRM");
pub const sRGB = kindFromBytes("sRGB");
pub const iCCP = kindFromBytes("iCCP");
pub const pHYs = kindFromBytes("pHYs");
pub const bKGD = kindFromBytes("bKGD");
pub const tIME = kindFromBytes("tIME");
pub const tEXt = kindFromBytes("tEXt");
pub const zTXt = kindFromBytes("zTXt");
pub const iTXt = kindFromBytes("iTXt");

size: u32,
kind: u32,
data: []const u8,
crc: u32,

pub fn init(size: u32, kind: u32, data: []const u8, crc: u32) Chunck {
    return .{
        .size = size,
        .kind = kind,
        .data = data,
        .crc = crc,
    };
}

fn kindFromBytes(comptime s: []const u8) u32 {
    return (@as(u32, s[0]) << 24) |
        (@as(u32, s[1]) << 16) |
        (@as(u32, s[2]) << 8) |
        (@as(u32, s[3]));
}

fn toString(kind: u32) [4]u8 {
    return .{
        @truncate(kind >> 24),
        @truncate(kind >> 16),
        @truncate(kind >> 8),
        @truncate(kind),
    };
}
