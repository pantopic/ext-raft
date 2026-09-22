const std = @import("std");

const buf_size: u32 = 2 * 1024 * 1024;

var meta: [8]u32 = undefined;
pub var flags: u16 = 0;
pub var shard_id: u64 = 0;
pub var replica_id: u64 = 0;
var index: u64 = 0;
var value: u64 = 0;
var buf_cap: u32 = buf_size;
var buf_len: u32 = 0;
var buf: [buf_size]u8 = undefined;

pub const Result = struct {
    value: u64 = 0,
    data: []const u8 = &.{},
};

pub const OpenFn = *const fn () u64;
pub const UpdateFn = *const fn (index: u64, cmd: []u8) Result;
pub const FinishFn = *const fn () void;
pub const ReadFn = *const fn (query: []u8) Result;
pub const StreamOpenFn = *const fn () void;
pub const StreamRecvFn = *const fn (cmd: []u8) void;
pub const StreamClosedFn = *const fn () void;
pub const WatchOpenFn = *const fn (cmd: []u8) void;
pub const WatchClosedFn = *const fn () void;

pub var fn_open: ?OpenFn = null;
pub var fn_update: ?UpdateFn = null;
pub var fn_finish: ?FinishFn = null;
pub var fn_read: ?ReadFn = null;
pub var fn_stream_open: ?StreamOpenFn = null;
pub var fn_stream_recv: ?StreamRecvFn = null;
pub var fn_stream_closed: ?StreamClosedFn = null;
pub var fn_watch_open: ?WatchOpenFn = null;
pub var fn_watch_closed: ?WatchClosedFn = null;

export fn __raft() u32 {
    meta[0] = @intFromPtr(&flags);
    meta[1] = @intFromPtr(&shard_id);
    meta[2] = @intFromPtr(&replica_id);
    meta[3] = @intFromPtr(&index);
    meta[4] = @intFromPtr(&value);
    meta[5] = @intFromPtr(&buf_cap);
    meta[6] = @intFromPtr(&buf_len);
    meta[7] = @intFromPtr(&buf[0]);
    return @intFromPtr(&meta[0]);
}

export fn __raft_open() u64 {
    return fn_open.?();
}

export fn __raft_update() void {
    const res = fn_update.?(index, buf[0..buf_len]);
    value = res.value;
    setData(res.data);
}

export fn __raft_finish() void {
    fn_finish.?();
}

export fn __raft_read() u64 {
    const res = fn_read.?(buf[0..buf_len]);
    value = res.value;
    if (res.data.len > 0) {
        return (@as(u64, @intFromPtr(res.data[0..res.data.len].ptr)) << 32) + @as(u64, res.data.len);
    }
    return 0;
}

export fn __raft_stream_open() void {
    if (fn_stream_open) |f| f();
}

export fn __raft_stream_recv() void {
    fn_stream_recv.?(buf[0..buf_len]);
}

export fn __raft_stream_closed() void {
    if (fn_stream_closed) |f| f();
}

export fn __raft_watch_open() void {
    fn_watch_open.?(buf[0..buf_len]);
}

export fn __raft_watch_closed() void {
    if (fn_watch_closed) |f| f();
}

pub fn setData(v: []const u8) void {
    std.mem.copyForwards(u8, buf[0..v.len], v);
    buf_len = @intCast(v.len);
}

pub fn setValue(v: u64) void {
    value = v;
}

pub extern "pantopic/ext-raft" fn __raft_stream_send() void;
pub extern "pantopic/ext-raft" fn __raft_stream_close() void;
pub extern "pantopic/ext-raft" fn __raft_watch_send() void;
pub extern "pantopic/ext-raft" fn __raft_watch_close() void;
