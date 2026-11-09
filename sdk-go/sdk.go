package raft

const (
	flagPersistent = 1 << iota
	flagStreamable
	flagWatchable
)

type (
	funcOpen         func() uint64
	funcUpdate       func(index uint64, cmd []byte) (value uint64, data []byte)
	funcCommit       func()
	funcAbort        func()
	funcRead         func(query []byte) (value uint64, data []byte)
	funcStreamOpen   func()
	funcStreamRecv   func(cmd []byte)
	funcStreamClosed func()
	funcWatchOpen    func(cmd []byte)
	funcWatchClosed  func()
)

var (
	fnOpen         funcOpen
	fnUpdate       funcUpdate
	fnCommit       funcCommit
	fnAbort        funcAbort
	fnRead         funcRead
	fnStreamOpen   funcStreamOpen
	fnStreamRecv   funcStreamRecv
	fnStreamClosed funcStreamClosed
	fnWatchOpen    funcWatchOpen
	fnWatchClosed  funcWatchClosed
)

func Concurrent(
	read funcRead,
	update funcUpdate,
	commit funcCommit,
	abort funcAbort,
) {
	fnRead = read
	fnUpdate = update
	fnCommit = commit
	fnAbort = abort
}

func Persistent(
	open funcOpen,
	read funcRead,
	update funcUpdate,
	commit funcCommit,
	abort funcAbort,
) {
	fnOpen = open
	fnRead = read
	fnUpdate = update
	fnCommit = commit
	fnAbort = abort
	flags |= flagPersistent
}

func Streaming(
	streamOpen funcStreamOpen,
	streamRecv funcStreamRecv,
	streamClosed funcStreamClosed,
) {
	fnStreamOpen = streamOpen
	fnStreamRecv = streamRecv
	fnStreamClosed = streamClosed
	flags |= flagStreamable
}

func StreamSend(val uint64, data []byte) {
	setValue(val)
	setData(data)
	streamSend()
}

func StreamClose() {
	streamClose()
}

func Watchable(
	watchOpen funcWatchOpen,
	watchClosed funcWatchClosed,
) {
	fnWatchOpen = watchOpen
	fnWatchClosed = watchClosed
	flags = flags & flagWatchable
}

func WatchSend(val uint64, data []byte) {
	setValue(val)
	setData(data)
	watchSend()
}

func WatchClose() {
	watchClose()
}
