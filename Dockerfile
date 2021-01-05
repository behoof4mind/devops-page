############################
# STEP 1 build executable binary
############################
FROM golang:1.15-alpine3.12 AS builder
# Git is required for fetching the dependencies.
RUN apk update && apk add --no-cache git=2.26.2-r0 ca-certificates=20191127-r4

WORKDIR $GOPATH/src/devops-page/
COPY . .
# Fetch dependencies using go get
RUN go get -d -v
# Build the binary.
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -o /root/devops-page/devops-page
COPY ./views /root/devops-page/views
COPY ./routes /root/devops-page/routes
COPY ./public /root/devops-page/public
RUN addgroup -S scratchuser \
  && adduser -S scratchuser -G scratchuser \
  && chown -R scratchuser:scratchuser /root/devops-page \
  && chown -R scratchuser:scratchuser /root/devops-page

############################
# STEP 2 build a small image
############################
FROM scratch
LABEL maintainer="dlavrushko@protonmail.com"
WORKDIR /app/
#COPY --from=builder /go/src/devops-page .
COPY --from=builder /root/devops-page/ .
COPY --from=builder /etc/passwd /etc/passwd
USER scratchuser
ENTRYPOINT ["/app/devops-page"]