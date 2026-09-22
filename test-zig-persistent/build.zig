const std = @import("std");

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{
        .preferred_optimize_mode = .ReleaseSmall,
    });
    const wasm_target = b.resolveTargetQuery(.{ .cpu_arch = .wasm32, .os_tag = .freestanding });
    const raft_dep = b.dependency("raft_sdk_zig", .{});
    const exe = b.addExecutable(.{
        .name = "test-zig-persistent",
        .root_module = b.createModule(.{
            .root_source_file = b.path("module.zig"),
            .target = wasm_target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "raft", .module = raft_dep.module("raft") },
            },
        }),
    });
    exe.entry = .disabled;
    exe.rdynamic = true;
    b.installArtifact(exe);
}
