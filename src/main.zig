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

fn nextLine(reader: anytype, buffer: []u8) !?[]u8 {
    var line = try reader.readUntilDelimiterOrEof(buffer, '\n') orelse return null;
    if (@import("builtin").os.tag == .windows) {
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

const MyByteList = struct {
    data: [100]u8 = undefined,
    items: []u8 = &[_]u8{},

    const Writer = std.io.Writer(
        *MyByteList,
        error{EndOfBuffer},
        appendWrite,
    );

    fn appendWrite(self: *MyByteList, data: []const u8) error{EndOfBuffer}!usize {
        if (self.items.len + data.len > self.data.len) {
            return error.EndOfBuffer;
        }
        @memcpy(self.data[self.items.len..][0..data.len], data);
        self.items = self.data[0 .. self.items.len + data.len];
        return data.len;
    }

    fn writer(self: *MyByteList) Writer {
        return .{ .context = self };
    }
};

test "custom writer" {
    var bytes = MyByteList{};
    _ = try bytes.writer().write("Hello");
    _ = try bytes.writer().write(" Writer");
    try std.testing.expect(std.mem.eql(u8, bytes.items, "Hello Writer"));

    const foo = try std.fmt.allocPrint(
        std.testing.allocator,
        "{s}",
        .{"Hello Yuya"},
    );
    defer std.testing.allocator.free(foo);

    try std.testing.expect(std.mem.eql(u8, foo, "Hello Yuya"));

    std.debug.print("\n{s}\n", .{foo});
}

test "json parse" {
    const Place = struct { foo: i32, bar: []const u8 };
    const parsed = try std.json.parseFromSlice(
        Place,
        test_allocator,
        \\{ "foo": 42, "bar": "hello" }
    ,
        .{},
    );
    defer parsed.deinit();

    const before = Place{ .foo = 42, .bar = "Hello" };
    var buffer: [100]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    var after = std.ArrayList(u8).init(fba.allocator());
    try std.json.stringify(before, .{}, after.writer());
    try std.testing.expect(std.mem.eql(u8, after.items,
        \\{"foo":42,"bar":"Hello"}
    ));

    const native = @import("builtin").cpu.arch.endian();
    const content = try std.fmt.allocPrint(
        std.testing.allocator,
        "{any}",
        .{native},
    );
    defer std.testing.allocator.free(content);

    try std.testing.expect(std.mem.eql(u8, content, "builtin.Endian.Little"));

    std.debug.print("\n{s}\n", .{content});
}
