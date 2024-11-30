FROM --platform=$BUILDPLATFORM golang:alpine AS builder
WORKDIR /go/src/github.com/nezhahq/agent
ARG TARGETOS TARGETARCH BRANCH
ENV CGO_ENABLED=0 \
    GOOS=$TARGETOS \
    GOARCH=$TARGETARCH \
    VERSION_NO_V=${BRANCH#v}
RUN set -ex \
    && apk add --no-cache git build-base \
    && git clone -b $BRANCH --single-branch --depth=1 https://github.com/nezhahq/agent /go/src/github.com/nezhahq/agent \
    && go version \
    && go mod tidy -v \
    && go build -v -trimpath \
    -o /go/bin/agent \
    -ldflags "-X \"github.com/nezhahq/agent/pkg/monitor.Version=$VERSION_NO_V\" -X \"main.arch=$TARGETARCH\" -s -w -buildid=" \
    ./cmd/agent
FROM alpine AS dist
COPY --from=builder /go/bin/agent /usr/local/bin/agent
ENTRYPOINT ["agent"]
