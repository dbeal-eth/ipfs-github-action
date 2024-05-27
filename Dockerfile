FROM --platform=${BUILDPLATFORM:-linux/amd64} golang:1.20-bullseye AS builder
MAINTAINER olizilla <oli@protocol.ai>

ARG TARGETPLATFORM TARGETOS TARGETARCH
ENV GOPATH /go

WORKDIR /tmp

ENV DNSLINK_DNSIMPLE_VERSION v0.1.0
ENV CLUSTER_VERSION v1.1.0

RUN go install github.com/ipfs-cluster/ipfs-cluster/cmd/ipfs-cluster-ctl@${CLUSTER_VERSION}
RUN go install github.com/ipfs/dnslink-dnsimple@${DNSLINK_DNSIMPLE_VERSION}

#------------------------------------------------------
FROM alpine:3.18

ENV GOPATH /go

RUN apk add --no-cache gcompat bash ca-certificates

COPY --from=builder $GOPATH/bin/dnslink-dnsimple /usr/local/bin/dnslink-dnsimple
COPY --from=builder $GOPATH/bin/ipfs-cluster-ctl /usr/local/bin/ipfs-cluster-ctl

ARG GIT_COMMIT=unspecified
LABEL git_commit=$GIT_COMMIT

COPY "entrypoint.sh" "/entrypoint.sh"

ENTRYPOINT ["/entrypoint.sh"]
