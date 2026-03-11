const std = @import("std");
const testing = std.testing;
const Decode = @This();
const Parser = @import("internal/Parser.zig");

comptime {
    testing.refAllDecls(Parser);
}
