const std = @import("std");
const builtin = @import("builtin");

pub fn main() anyerror!void {
    try std.debug.print("{any}", .{builtin.os.tag == .windows});
}
