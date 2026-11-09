const std = @import("std");
const abi = @import("abi.zig");

pub const Result = abi.Result;

const flag_persistent: u16 = 1 << 0;
const flag_streamable: u16 = 1 << 1;
const flag_watchable: u16 = 1 << 2;

pub fn shardID() u64 {
    return abi.shard_id;
}

pub fn replicaID() u64 {
    return abi.replica_id;
}

pub fn concurrent(read: abi.ReadFn, update: abi.UpdateFn, commit: abi.CommitFn, abort: abi.AbortFn) void {
    abi.fn_read = read;
    abi.fn_update = update;
    abi.fn_commit = commit;
    abi.fn_abort = abort;
}

pub fn persistent(read: abi.ReadFn, open: abi.OpenFn, update: abi.UpdateFn, commit: abi.CommitFn, abort: abi.AbortFn) void {
    abi.fn_open = open;
    abi.fn_read = read;
    abi.fn_update = update;
    abi.fn_commit = commit;
    abi.fn_abort = abort;
    abi.flags |= flag_persistent;
}

pub fn streaming(streamOpen: abi.StreamOpenFn, streamRecv: abi.StreamRecvFn, streamClosed: abi.StreamClosedFn) void {
    abi.fn_stream_open = streamOpen;
    abi.fn_stream_recv = streamRecv;
    abi.fn_stream_closed = streamClosed;
    abi.flags |= flag_streamable;
}

pub fn streamSend(val: u64, data: []const u8) void {
    abi.setValue(val);
    abi.setData(data);
    abi.__raft_stream_send();
}

pub fn streamClose() void {
    abi.__raft_stream_close();
}

pub fn watchable(watchOpen: abi.WatchOpenFn, watchClosed: abi.WatchClosedFn) void {
    abi.fn_watch_open = watchOpen;
    abi.fn_watch_closed = watchClosed;
    abi.flags |= flag_watchable;
}

pub fn watchSend(val: u64, data: []const u8) void {
    abi.setValue(val);
    abi.setData(data);
    abi.__raft_watch_send();
}

pub fn watchClose() void {
    abi.__raft_watch_close();
}
