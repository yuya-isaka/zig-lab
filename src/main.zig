const std = @import("std");
const builtin = @import("builtin");
const ArrayList = std.ArrayList;
const test_allocator = std.testing.allocator;

test "io writer usage" {
    var list = ArrayList(u8).init(test_allocator);
    defer list.deinit();
    const bytes_written = try list.writer().writeAll(
        "Hello World",
    );
    // 12じゃない？
    try std.testing.expect(@TypeOf(bytes_written) == void);
    try std.testing.expect(std.mem.eql(u8, list.items, "Hello World"));
}

test "io reader usage" {
    const message = "Hello File!";

    const file = try std.fs.cwd().createFile(
        "yuya-isaka.txt",
        .{ .read = true },
    );
    defer file.close();

    try file.writeAll(message);
    try file.seekTo(0);

    const contents = try file.reader().readAllAlloc(test_allocator, message.len);
    defer test_allocator.free(contents);

    try std.testing.expect(std.mem.eql(u8, contents, message));
}

fn nextLine(reader: anytype, buffer: []u8) !?[]const u8 {
    // 指定されたデリミタ（'\n'）かファイルの終わり（EOF）まで読み取る
    var line = try reader.readUntilDelimiterOrEof(buffer, '\n') orelse return null;
    if (builtin.os.tag == .windows) {
        //  行の末尾から\r（キャリッジリターン、Windowsの改行スタイルで一般的）を削除します。これは、Windowsでは改行が\r\nで表されるため、読み取り時に\rが余計に含まれてしまう場合があるためです。
        return std.mem.trimRight(u8, line, "\r");
    } else {
        return line;
    }
}

test "read until next line" {
    const stdout = std.io.getStdOut();
    const stdin = std.io.getStdIn();

    try stdout.writeAll("\nEnter your name:");

    var buffer: [100]u8 = undefined;
    const input = (try nextLine(stdin.reader(), &buffer)).?;
    try stdout.writer().print(
        "What is your name? {s}",
        .{input},
    );
}
