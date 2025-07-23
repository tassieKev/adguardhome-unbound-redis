FROM alpine:3.22 AS base

ARG TARGETARCH

# Install dependencies
RUN apk update && apk upgrade && \
    apk add --no-cache redis unbound busybox-suid curl build-base openssl-dev \
    libexpat expat-dev hiredis-dev libcap-dev libevent-dev perl wget

# Compile Unbound with hiredis support
RUN wget https://nlnetlabs.nl/downloads/unbound/unbound-latest.tar.gz && \
    mkdir unbound-latest && tar -xzf unbound-latest.tar.gz --strip-components=1 -C unbound-latest && \
    (cd unbound-latest && \
    ./configure --with-libhiredis --with-libexpat=/usr --with-libevent --enable-cachedb --disable-flto --disable-shared --disable-rpath --with-pthreads && \
    make && make install) && rm -rf unbound-latest*

# Download AdGuardHome binary based on architecture
RUN LATEST_VERSION="$(curl -s https://api.github.com/repos/AdguardTeam/AdGuardHome/releases/latest | grep '\"tag_name\"' | sed -E 's/.*\"([^\"]+)\".*/\1/')" && \
    ARCHIVE_NAME="AdGuardHome_linux_${TARGETARCH}.tar.gz" && \
    curl -L -o /tmp/AdGuardHome.tar.gz "https://github.com/AdguardTeam/AdGuardHome/releases/download/${LATEST_VERSION}/${ARCHIVE_NAME}" && \
    tar -xzf /tmp/AdGuardHome.tar.gz -C /opt && \
    rm /tmp/AdGuardHome.tar.gz

# Create necessary directories
RUN mkdir -p /opt/adguardhome/work /config_default && \
    chmod 777 /config_default

# Copy configuration files from local source
COPY config/ /config_default

# Copy initialization script and make it executable
COPY init-config.sh /usr/local/bin/init-config.sh
RUN chmod +x /usr/local/bin/init-config.sh

# Expose required ports for various services
# 53 : TCP, UDP : DNS
# 67 : UDP : DHCP (server)
# 68 : UDP : DHCP (client)
# 80 : TCP : HTTP (main)
# 443 : TCP, UDP : HTTPS, DNS-over-HTTPS (incl. HTTP/3), DNSCrypt (main)
# 853 : TCP, UDP : DNS-over-TLS, DNS-over-QUIC
# 3000 : TCP, UDP : HTTP(S) (alt, incl. HTTP/3)
# 5443 : TCP, UDP : DNSCrypt (alt)
# 6060 : TCP : HTTP (pprof)
EXPOSE 53/tcp 53/udp 67/udp 68/udp 80/tcp 443/tcp 443/udp \
       853/tcp 853/udp 3000/tcp 3000/udp 5443/tcp 5443/udp \
       6060/tcp 6379 5053 784/udp 3002/tcp

# Set configuration environment variable
ENV XDG_CONFIG_HOME=/config

# Start services and ensure the last process remains in the foreground
CMD ["/bin/sh", "-c", "/usr/local/bin/init-config.sh && \
    redis-server /config/redis/redis.conf & \
    unbound -d -c /config/unbound/unbound.conf & \
    exec /opt/AdGuardHome/AdGuardHome -c /config/AdGuardHome/AdGuardHome.yaml -w /config"]
