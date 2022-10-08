FROM golang:1.19.2-alpine3.16 as builder

MAINTAINER smallnest <smallnest@gmail.com>

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
RUN apk update && apk add --no-cache bash git

ENV GOPROXY=https://goproxy.cn,direct
ENV GO111MODULE=on

WORKDIR /repo

# all the steps are cached
ADD go.mod .
ADD go.sum .
# if go.mod/go.sum not changed, this step is also cached
RUN go mod download

ADD . ./

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o gowebbenchmark .

FROM alpine:3.16

MAINTAINER smallnest <smallnest@gmail.com>

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
RUN apk update && apk add --no-cache bash openssl wrk gnuplot curl

VOLUME ["/data"]

COPY --from=builder /repo /repo

WORKDIR /repo

CMD ["/bin/sh","./docker-test.sh"]
