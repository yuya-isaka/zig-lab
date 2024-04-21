const std = @import("std");

fn fizzbuzz(writer: anytype, i: u32) !void {
    if (i % 15 == 0) {
        try writer.print("{s}\n", .{"FizzBuzz"});
    } else if (i % 3 == 0) {
        try writer.print("{s}\n", .{"Fizz"});
    } else if (i % 5 == 0) {
        try writer.print("{s}\n", .{"Buzz"});
    } else {
        try writer.print("{}\n", .{i});
    }
}

pub fn main() anyerror!void {
    const stdout = std.io.getStdOut().writer();
    var i: u32 = 1;
    while (i <= 100) : (i += 1) {
        try fizzbuzz(stdout, i);
    }
}

test "basic test" {
    var bytes = std.ArrayList(u8).init(std.testing.allocator);
    defer bytes.deinit();

    const TestType = struct { input: u8, want: []const u8 };
    const tests = [_]TestType{
        .{ .input = 1, .want = "1\n" },
        .{ .input = 2, .want = "2\n" },
        .{ .input = 3, .want = "Fizz\n" },
        .{ .input = 4, .want = "4\n" },
        .{ .input = 5, .want = "Buzz\n" },
        .{ .input = 6, .want = "Fizz\n" },
        .{ .input = 7, .want = "7\n" },
        .{ .input = 8, .want = "8\n" },
        .{ .input = 9, .want = "Fizz\n" },
        .{ .input = 10, .want = "Buzz\n" },
        .{ .input = 11, .want = "11\n" },
        .{ .input = 12, .want = "Fizz\n" },
        .{ .input = 13, .want = "13\n" },
        .{ .input = 14, .want = "14\n" },
        .{ .input = 15, .want = "FizzBuzz\n" },
    };

    for (tests) |t| {
        bytes.clearAndFree();
        std.debug.print("\n{d}", .{t.input});
        try fizzbuzz(bytes.writer(), t.input);
        try std.testing.expect(std.mem.eql(u8, bytes.items, t.want));
    }

    // items(), items.len, append(), appendSlice(), pop(), clearAndFree(), writer()
    // 追加領域を確保した後も、それまで格納されていたデータは元の位置に残る
    const L = std.SegmentedList(u32, 2);
    var list = L{};
    defer list.deinit(std.testing.allocator);
    try list.append(std.testing.allocator, 1);
    try list.append(std.testing.allocator, 2);
    try list.append(std.testing.allocator, 3);
    // try std.testing.expectEqual(@as(usize, 3), list.count());
    {
        // var it = list.constIterator(0);
        var it = list.iterator(0);
        var s: u32 = 0;
        while (it.next()) |item| {
            s += item.*;
        }
        // try std.testing.expectEqual(@as(u32, 6), s);
    }
}
