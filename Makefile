work:
	go work use sdk-go
	go work use test-go-concurrent
	go work use test-go-persistent
	go work use host-wazero

wasm-go:
	@cd test-go-concurrent && tinygo build -buildmode=wasi-legacy -target=wasi -opt=2 -gc=leaking -scheduler=none -o ../host/test-go-concurrent.wasm
	@cd test-go-persistent && tinygo build -buildmode=wasi-legacy -target=wasi -opt=2 -gc=leaking -scheduler=none -o ../host/test-go-persistent.wasm

wasm-zig:
	@cd test-zig-concurrent && zig build-exe -target wasm32-wasi -O ReleaseSmall -fno-entry -rdynamic --dep raft -Mroot=module.zig -raft=../sdk-zig/raft.zig -femit-bin=../host/test-zig-concurrent.wasm
	@cd test-zit-persistent && zig build-exe -target wasm32-wasi -O ReleaseSmall -fno-entry -rdynamic --dep raft -Mroot=module.zig -raft=../sdk-zig/raft.zig -femit-bin=../host/test-zig-persistent.wasm

wasm: wasm-go wasm-zig

test:
	@cd host && go test . -v -cover

bench:
	@cd host && go test -bench=. -v -run=Benchmark.*

cover:
	@mkdir -p _dist
	@cd host-wazero && go test . -coverprofile=../_dist/coverage.out -v
	@go tool cover -html=_dist/coverage.out -o _dist/coverage.html

cloc:
	@cloc . --exclude-dir=_example,_dist,internal,cmd --exclude-ext=pb.go

.PHONY: all test clean
