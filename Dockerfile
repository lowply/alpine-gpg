FROM alpine:latest
WORKDIR /root
RUN apk add gnupg bash curl
ENTRYPOINT /bin/bash
