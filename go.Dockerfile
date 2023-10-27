FROM golang:1.21.3-bookworm

WORKDIR /d3fau1t
COPY app/go/src ./src
COPY app/go/go.mod app/go/go.sum app/go/redis-client ./
RUN go mod tidy
RUN mkdir ./bin && cd src && go build -o /d3fau1t/bin/main
