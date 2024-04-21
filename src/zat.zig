const std = @import("std");

fn zat(writer: anytype, reader: anytype) !void {
    var buf: [std.mem.page_size]u8 = undefined;
    while (true) {
        const num_read = try reader.read(buf[0..]);
        if (num_read <= 1) break;
        try writer.print(
            "{d} bytes\n\n",
            .{num_read - 1},
        );
        try writer.writeAll(buf[0..num_read]);
    }
}

pub fn main() anyerror!void {
    var allocator = std.heap.page_allocator;

    const args = try std.process.argsAlloc(allocator);
    defer allocator.free(args);

    const writer = std.io.getStdOut().writer();
    if (args.len > 1) {
        for (args[1..args.len]) |arg| {
            const file = try std.fs.cwd().openFile(arg, .{ .mode = .read_only });
            defer file.close();
            zat(writer, file) catch |err| {
                std.log.warn("error reading file '{s}': {}", .{ arg, err });
            };
        }
    } else {
        zat(writer, std.io.getStdIn().reader()) catch |err| {
            std.log.warn("error reading stdin: {}", .{err});
        };
    }
}
