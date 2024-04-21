const std = @import("std");

fn brainfuck(allocator: std.mem.Allocator, code: []const u8) !void {
    // items, items.len, try append(), try appendSlice(), try pop(), try clearAndFree(), writer()
    var list = std.ArrayList(u8).init(allocator);
    defer list.deinit();

    try list.append(0);
    var dlen: usize = 0;

    var pc: usize = 0;
    while (pc < code.len) : (pc += 1) {
        switch (code[pc]) {
            '+' => {
                list.items[dlen] +%= 1;
            },
            '-' => {
                list.items[dlen] -%= 1;
            },
            '>' => {
                dlen += 1;
                if (list.items.len <= dlen) {
                    try list.append(0);
                }
            },
            '<' => {
                if (dlen > 0) {
                    dlen -= 1;
                }
            },
            '.' => {
                try std.io.getStdOut().writer().print("{c}", .{list.items[dlen]});
            },
            ',' => {
                list.items[dlen] = try std.io.getStdIn().reader().readByte();
            },
            '[' => {
                if (list.items[dlen] == 0) {
                    var depth: u32 = 1;
                    while (depth > 0) {
                        pc += 1;
                        var src_character = code[pc];
                        if (src_character == '[') {
                            depth += 1;
                        } else if (src_character == ']') {
                            depth -= 1;
                        }
                    }
                }
            },
            ']' => {
                var depth: u32 = 1;
                while (depth > 0) {
                    pc -= 1;
                    var src_character = code[pc];
                    if (src_character == '[') {
                        depth -= 1;
                    } else if (src_character == ']') {
                        depth += 1;
                    }
                }
                pc -= 1;
            },
            else => {},
        }
    }
}

pub fn main() anyerror!void {
    var allocator = std.heap.page_allocator;
    const reader = std.io.getStdIn().reader();
    while (true) {
        var code = try reader.readUntilDelimiterOrEofAlloc(allocator, '\n', 1000);
        if (code == null) break;
        try brainfuck(allocator, code.?);
    }
}
