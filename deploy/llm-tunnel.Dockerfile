FROM alpine:3.22
RUN apk add --no-cache openssh-client
ENTRYPOINT ["ssh", "-F", "/ssh/config", "-N", "-o", "ExitOnForwardFailure=yes", "-o", "ServerAliveInterval=30", "-o", "ServerAliveCountMax=3", "-L", "0.0.0.0:29913:127.0.0.1:29913", "qwen-target"]
