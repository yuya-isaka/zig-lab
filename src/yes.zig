const std = @import("std");

pub fn main() anyerror!void {
    var allocator = std.heap.page_allocator;
    const args = try std.process.argsAlloc(allocator);
    defer allocator.free(args);
    // items(), items.len, append(), appendSlice(), pop(), clearAndFree(), writer()
    var list = std.ArrayList(u8).init(allocator);
    defer list.deinit();
    var list_writer = list.writer();
    if (args.len > 1) {
        for (args[1..args.len], 0..) |tmp, i| {
            if (i > 0) try list_writer.writeAll(" ");
            try list_writer.writeAll(tmp);
        }
    } else {
        try list_writer.writeAll("y");
    }
    try list_writer.writeAll("\n");

    // items(), items.len, append(), appendSlice(), pop(), clearAndFree(), writer()
    var buf = std.ArrayList(u8).init(allocator);
    defer buf.deinit();

    const buf_size = 64 * 1024;
    var copy_size = list.items.len;

    var copies = buf_size / copy_size;
    while (copies > 0) {
        try buf.writer().writeAll(list.items);
        copies -= 1;
    }

    const stdout = std.io.getStdOut().writer();
    while (true) {
        try stdout.writeAll(buf.items);
    }
}
