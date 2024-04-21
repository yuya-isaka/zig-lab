const std = @import("std");

pub fn main() anyerror!void {
    var allocator = std.heap.page_allocator;
    var p = std.json.Parser.init(allocator, false);
    defer p.deinit();

    const args = try std.process.argsAlloc(allocator);
    defer allocator.free(args);

    const stdout = std.io.getStdOut();

    var is_array = false;

    // items(), items.len, append(), appendSlice(), pop(), clearAndFree(), writer()
    var list = std.ArrayList([]const u8).init(allocator);
    defer list.deinit();

    for (args[1..args.len]) |aa| {
        if (std.mem.eql(u8, aa, "-a")) {
            is_array = true;
        } else {
            try list.append(aa);
        }
    }

    if (is_array) {
        var a = std.json.Array.init(allocator);
        defer a.deinit();

        for (list.items) |tmp| {
            if (p.parse(tmp)) |v| {
                try a.append(v.root);
            } else |_| {
                try a.append(std.json.Value{ .String = tmp });
            }
        }
        try (std.json.Value{ .Array = a }).jsonStringify(.{}, stdout);
    } else {
        var m = std.json.ObjectMap.init(allocator);
        defer m.deinit();

        for (list.items) |tmp| {
            var it = std.mem.split(u8, tmp, "=");
            var key = it.next() orelse "";
            var value = it.next() orelse "";
            if (p.parse(value)) |v| {
                try m.put(key, v.root);
            } else {
                try m.put(key.std.json.Value{ .String = tmp });
            }
        }
        try (std.json.Value{ .Object = m }).jsonStringify(.{}, stdout);
    }
    try stdout.write("\n");
}
