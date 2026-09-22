package main

import (
	"bytes"
	"strconv"

	"github.com/pantopic/ext-raft/sdk-go"
)

var (
	idx   uint64
	items uint64
	sets  uint64
)

func main() {
	raft.Persistent(open, update, finish, read)
	raft.Streaming(streamOpen, streamRecv, streamClosed)
	raft.Watchable(watchOpen, watchClosed)
}

func open() uint64 {
	return 0
}

func update(index uint64, cmd []byte) (value uint64, data []byte) {
	items++
	value = idx
	idx = index
	data = bytes.ReplaceAll(cmd, []byte(`test`), []byte(`best`))
	return
}

func finish() {
	sets++
}

var (
	queryIndex = []byte(`index`)
	queryItems = []byte(`items`)
	querySets  = []byte(`sets`)
)

func read(query []byte) (value uint64, data []byte) {
	if bytes.Equal(query, queryIndex) {
		value = idx
	} else if bytes.Equal(query, queryItems) {
		value = items
	} else if bytes.Equal(query, querySets) {
		value = sets
	} else {
		panic(`Unrecognized query: "` + string(query) + `"`)
	}
	return
}

func streamOpen() {
}

func streamRecv(data []byte) {
	if bytes.Equal(data, []byte(`close`)) {
		raft.StreamClose()
	} else {
		raft.StreamSend(1, data)
	}
}

func streamClosed() {
}

func watchOpen(data []byte) {
	n, err := strconv.Atoi(string(data))
	if err != nil {
		panic(err)
	}
	for i := range n {
		raft.WatchSend(1, []byte(strconv.Itoa(i+1)))
	}
	raft.WatchClose()
}

func watchClosed() {
}
