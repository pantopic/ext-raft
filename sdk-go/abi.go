package raft

import (
	"unsafe"
)

var (
	flags     uint16
	ShardID   uint64
	ReplicaID uint64
	index     uint64
	value     uint64
	bufCap    uint32 = 2 * 1024 * 1024
	bufLen    uint32
	buf       = make([]byte, int(bufCap))
	tmp       []byte
	meta      = make([]uint32, 8)
)

//export __raft
func __raft() uint32 {
	for i, p := range []unsafe.Pointer{
		unsafe.Pointer(&flags),
		unsafe.Pointer(&ShardID),
		unsafe.Pointer(&ReplicaID),
		unsafe.Pointer(&index),
		unsafe.Pointer(&value),
		unsafe.Pointer(&bufCap),
		unsafe.Pointer(&bufLen),
		unsafe.Pointer(&buf[0]),
	} {
		meta[i] = uint32(uintptr(p))
	}
	return uint32(uintptr(unsafe.Pointer(&meta[0])))
}

//export __raft_open
func open() uint64 {
	return fnOpen()
}

//export __raft_update
func update() {
	value, tmp = fnUpdate(index, buf[:int(bufLen)])
	copy(buf[:len(tmp)], tmp)
	bufLen = uint32(len(tmp))
}

//export __raft_finish
func finish() {
	fnFinish()
}

//export __raft_read
func read() (res uint64) {
	value, tmp = fnRead(buf[:int(bufLen)])
	if len(tmp) > 0 {
		res = (uint64(uintptr(unsafe.Pointer(&tmp[0]))) << 32) + uint64(len(tmp))
	}
	return
}

//export __raft_stream_open
func stream_open() {
	if fnStreamOpen != nil {
		fnStreamOpen()
	}
}

//export __raft_stream_recv
func stream_recv() {
	fnStreamRecv(buf[:int(bufLen)])
}

//export __raft_stream_closed
func stream_closed() {
	if fnStreamClosed != nil {
		fnStreamClosed()
	}
}

//export __raft_watch_open
func watch_open() {
	fnWatchOpen(buf[:int(bufLen)])
}

//export __raft_watch_closed
func watch_closed() {
	if fnWatchClosed != nil {
		fnWatchClosed()
	}
}

func setData(v []byte) {
	copy(buf[:len(v)], v)
	bufLen = uint32(len(v))
}

func setValue(v uint64) {
	value = v
}

//go:wasm-module pantopic/ext-raft
//export __raft_stream_send
func streamSend()

//go:wasm-module pantopic/ext-raft
//export __raft_stream_close
func streamClose()

//go:wasm-module pantopic/ext-raft
//export __raft_watch_send
func watchSend()

//go:wasm-module pantopic/ext-raft
//export __raft_watch_close
func watchClose()

var _ = __raft
var _ = open
var _ = update
var _ = finish
var _ = read
var _ = stream_open
var _ = stream_recv
var _ = stream_closed
var _ = watch_open
var _ = watch_closed
