work:
	go work use sdk-go
	go work use test-go-concurrent
	go work use test-go-persistent
	go work use host-wazero

wasm-go:
	@cd test-go-concurrent && tinygo build -buildmode=wasi-legacy -target=wasi -opt=2 -gc=leaking -scheduler=none -o ../host-wazero/test-go-concurrent.wasm
	@cd test-go-persistent && tinygo build -buildmode=wasi-legacy -target=wasi -opt=2 -gc=leaking -scheduler=none -o ../host-wazero/test-go-persistent.wasm

wasm-zig:
	@cd test-zig-concurrent && zig build
	@cp test-zig-concurrent/zig-out/bin/test-zig-concurrent.wasm host-wazero/test-zig-concurrent.wasm
	@cd test-zig-persistent && zig build
	@cp test-zig-persistent/zig-out/bin/test-zig-persistent.wasm host-wazero/test-zig-persistent.wasm

wasm: wasm-go wasm-zig

test:
	@cd host-wazero && go test . -v -cover

bench:
	@cd host-wazero && go test -bench=. -v -run=Benchmark.*

cover:
	@mkdir -p _dist
	@cd host-wazero && go test . -coverprofile=../_dist/coverage.out -v
	@go tool cover -html=_dist/coverage.out -o _dist/coverage.html

cloc:
	@cloc . --exclude-dir=_example,_dist,internal,cmd --exclude-ext=pb.go

.PHONY: all test clean
