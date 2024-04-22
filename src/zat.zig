const std = @import("std");

fn zat(writer: std.fs.File.Writer, fd: std.fs.File.Reader) !void {
    // バッファ
    var buf: [std.mem.page_size]u8 = undefined;

    while (true) {
        // read関数
        const num_read = try fd.read(buf[0..]);
        if (num_read <= 1) break;

        // print関数
        try writer.print(
            "{d} bytes\n\n",
            .{num_read - 1},
        );
        try writer.writeAll(buf[0..num_read]);
    }
}

pub fn main() anyerror!void {
    // アロケータ
    var allocator = std.heap.page_allocator;

    // 引数取得
    const args = try std.process.argsAlloc(allocator);
    defer allocator.free(args);

    // ライター
    const writer = std.io.getStdOut().writer();

    if (args.len > 1) {
        for (args[1..args.len]) |arg| {

            // オープン
            const fd = std.fs.cwd().openFile(arg, .{ .mode = .read_only }) catch |err| {
                const msg = try std.fmt.allocPrint(
                    allocator,
                    "Error: {any}",
                    .{err},
                );
                defer allocator.free(msg);
                @compileError(msg);
            };
            defer fd.close();

            // fdから読み込んで、writerに書き込む
            zat(writer, fd.reader()) catch |err| {
                std.log.warn("error reading file '{s}': {}", .{ arg, err });
            };
        }
    } else {
        const fd = std.io.getStdIn().reader();
        zat(writer, fd) catch |err| {
            std.log.warn("error reading stdin: {}", .{err});
        };
    }
}
