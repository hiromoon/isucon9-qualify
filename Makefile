export GO111MODULE=on

all: bin/benchmarker bin/benchmark-worker bin/payment bin/shipment

bin/benchmarker: cmd/bench/main.go bench/**/*.go
	go build -o bin/benchmarker cmd/bench/main.go

bin/benchmark-worker: cmd/bench-worker/main.go
	go build -o bin/benchmark-worker cmd/bench-worker/main.go

bin/payment: cmd/payment/main.go bench/server/*.go
	go build -o bin/payment cmd/payment/main.go

bin/shipment: cmd/shipment/main.go bench/server/*.go
	go build -o bin/shipment cmd/shipment/main.go

vet:
	go vet ./...

errcheck:
	errcheck ./...

staticcheck:
	staticcheck -checks="all,-ST1000" ./...

clean:
	rm -rf bin/*

.PHONY: bench
bench:
	ssh isucon-bench 'cd isucari && ulimit -Sn 100000 && make start-bench'

deploy:
	cd webapp/go && make isucari && cd -
	ssh isucon 'sudo systemctl stop isucari.golang.service'
	scp ./webapp/go/isucari isucon:~/isucari/webapp/go
	ssh isucon 'sudo systemctl start isucari.golang.service'

deploy-login:
	cd webapp/go && make isucari && cd -
	ssh isucon2 'sudo systemctl stop isucari.golang.service'
	scp ./webapp/go/isucari isucon2:~/isucari/webapp/go
	ssh isucon2 'sudo systemctl start isucari.golang.service'
