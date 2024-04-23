const std = @import("std");

test "simple test" {
    var buf: [255]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buf);

    const stream = fbs.writer();
    try stream.print("{s}!", .{"Hello"});
    try std.testing.expectEqualSlices(u8, "Hello!", fbs.getWritten());

    try fbs.seekTo(0);

    var dest: [4]u8 = undefined;
    var read = try fbs.reader().read(&dest);
    try std.testing.expect(read == 4);
    try std.testing.expectEqualSlices(u8, dest[0..4], buf[0..4]);
}
