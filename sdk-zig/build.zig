const std = @import("std");

pub fn build(b: *std.Build) void {
    _ = b.addModule("raft", .{
        .root_source_file = b.path("src/sdk.zig"),
    });
}
