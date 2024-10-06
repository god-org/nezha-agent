FROM --platform=$BUILDPLATFORM golang:alpine AS builder
WORKDIR /go/src/github.com/nezhahq/agent
ARG TARGETOS TARGETARCH BRANCH
ENV CGO_ENABLED=0
ENV GOOS=$TARGETOS
ENV GOARCH=$TARGETARCH
ENV VERSION_NO_V=${BRANCH#v}
RUN set -ex \
  && apk add --no-cache git build-base \
  && git clone -b $BRANCH --single-branch --depth=1 https://github.com/nezhahq/agent /go/src/github.com/nezhahq/agent \
  && go mod tidy \
  && go build -v -trimpath \
  -o /go/bin/agent \
  -ldflags "-X \"main.version=$VERSION_NO_V\" -X \"main.arch=$TARGETARCH\" -s -w -buildid=" \
  ./cmd/agent
FROM alpine AS dist
#RUN set -ex \
#  && apk upgrade \
#  && apk add --no-cache bash tzdata ca-certificates nftables \
#  && rm -rf /var/cache/apk/*
COPY --from=builder /go/bin/agent /usr/local/bin/agent
ENTRYPOINT [ "agent" ]
