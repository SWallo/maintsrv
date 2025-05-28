# syntax=docker/dockerfile:1

FROM --platform=$BUILDPLATFORM golang:1.24.3 AS build
LABEL maintainer="Sven Walloner <coding@walloner.de>"

ARG TARGETARCH
WORKDIR /src
COPY . .
RUN make build ARCH=$TARGETARCH

FROM alpine:3.21
RUN apk --no-cache add ca-certificates tzdata wget

ARG TARGETARCH
COPY --from=build /src/maintsrv /maintsrv
COPY --from=build /src/static /static

ENV STATIC_DIR="/static"
EXPOSE 8080

USER 10001:10001
WORKDIR /

ENTRYPOINT ["/maintsrv"]

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 CMD wget --spider -q http://localhost:8080/healthz || exit 1