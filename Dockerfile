FROM debian:bookworm-slim
LABEL maintainer="czytcn@gmail.com"

ENV DEBIAN_FRONTEND=noninteractive
ARG IVENTOY_VERSION
ENV IVENTOY_VERSION=${IVENTOY_VERSION:-1.0.39}

RUN apt-get update && apt-get install -y --no-install-recommends curl libglib2.0-dev libevent-dev libwim-dev && \
    rm -rf /var/lib/apt/lists/*

ARG TARGETARCH

RUN case "${TARGETARCH}" in \
      amd64) ARCH_SUFFIX="x86_64"; EDITION="free" ;; \
      arm64) ARCH_SUFFIX="arm64"; EDITION="trial" ;; \
      *) echo "Unsupported architecture: ${TARGETARCH}"; exit 1 ;; \
    esac && \
    curl -kL "https://github.com/ventoy/PXE/releases/download/v${IVENTOY_VERSION}/iventoy-${IVENTOY_VERSION}-linux-${ARCH_SUFFIX}-${EDITION}.tar.gz" -o /tmp/iventoy.tar.gz && \
    tar -xvzf /tmp/iventoy.tar.gz -C /tmp && \
    mv /tmp/iventoy-${IVENTOY_VERSION} /iventoy && \
    chmod +x /iventoy/lib/iventoy && \
    mkdir -p /usr/share/iventoy/data && \
    cp /iventoy/data/iventoy.dat /iventoy/data/mac.db /usr/share/iventoy/data/ && \
    rm -f /tmp/iventoy.tar.gz

COPY --chmod=755 files/docker-entrypoint.sh /usr/local/bin/docker-entrypoint

RUN ln -sf /proc/1/fd/1 /iventoy/log/log.txt

EXPOSE 26000 16000 10809 69/udp
ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]
