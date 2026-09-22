const std = @import("std");
const raft = @import("raft");

pub const std_options_debug_io: std.Io = undefined;

comptime {
    _ = raft;
}

var idx: u64 = 0;
var items: u64 = 0;
var sets: u64 = 0;

export fn _start() void {
    raft.persistent(open, update, finish, read);
    raft.streaming(streamOpen, streamRecv, streamClosed);
    raft.watchable(watchOpen, watchClosed);
}

fn open() u64 {
    return 0;
}

fn update(index: u64, cmd: []u8) raft.Result {
    items += 1;
    const value = idx;
    idx = index;
    var i: usize = 0;
    while (std.mem.indexOfPos(u8, cmd, i, "test")) |pos| {
        @memcpy(cmd[pos .. pos + 4], "best");
        i = pos + 4;
    }
    return .{ .value = value, .data = cmd };
}

fn finish() void {
    sets += 1;
}

fn read(query: []u8) raft.Result {
    if (std.mem.eql(u8, query, "index")) {
        return .{ .value = idx };
    } else if (std.mem.eql(u8, query, "items")) {
        return .{ .value = items };
    } else if (std.mem.eql(u8, query, "sets")) {
        return .{ .value = sets };
    }
    @panic("Unrecognized query");
}

fn streamOpen() void {}

fn streamRecv(data: []u8) void {
    if (std.mem.eql(u8, data, "close")) {
        raft.streamClose();
    } else {
        raft.streamSend(1, data);
    }
}

fn streamClosed() void {}

fn watchOpen(data: []u8) void {
    const n = std.fmt.parseInt(u64, data, 10) catch @panic("Invalid watch count");
    var i: u64 = 1;
    var tmp: [20]u8 = undefined;
    while (i <= n) : (i += 1) {
        const s = std.fmt.bufPrint(&tmp, "{d}", .{i}) catch unreachable;
        raft.watchSend(1, s);
    }
    raft.watchClose();
}

fn watchClosed() void {}
