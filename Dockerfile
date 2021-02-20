FROM alpine:latest
LABEL maintainer="Sebastian Mauer (mauimauer at gmail dot com)"

ENV S6_OVERLAY_VERSION=v2.2.0.1 \ 
    DEBUG_MODE=FALSE \
    TIMEZONE=Etc/GMT \
    ENABLE_CRON=TRUE \
    ENABLE_LOGROTATE=TRUE

### Install Dependencies
RUN set -x && \
    apk update && \
    apk upgrade && \
    apk add -t .base-rundeps \
            bash \
            busybox-extras \
            curl \
            drill \
            grep \
            less \
            openssl \
            logrotate \
            sudo \
            tzdata \
            unbound \
            && \
    mkdir /usr/src && \
    cd /usr/src && \
### S6 installation
    apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		x86_64) s6Arch='amd64' ;; \
		armv7) s6Arch='arm' ;; \
                armhf) s6Arch='armhf' ;; \
		aarch64) s6Arch='aarch64' ;; \
		ppc64le) s6Arch='ppc64le' ;; \
		*) echo >&2 "Error: unsupported architecture ($apkArch)"; exit 1 ;; \
	esac; \
    curl -sSL https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-${s6Arch}.tar.gz | tar xfz - -C / && \
    mkdir -p /assets/cron && \
### Clean up
    rm -rf /usr/src/* && \
    rm -rf /var/cache/apk/*

### Add folders
ADD /install /

### Entrypoint configuration
ENTRYPOINT ["/init"]

### Networking Configuration
EXPOSE 2053/udp

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
	CMD [ "drill", "-p", "2053", "google.com", "@127.0.0.1" ]
