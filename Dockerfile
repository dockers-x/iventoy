FROM debian:bookworm-slim
LABEL maintainer="czytcn@gmail.com"

ENV DEBIAN_FRONTEND=noninteractive
ARG IVENTOY_VERSION
ENV IVENTOY_VERSION=${IVENTOY_VERSION:-1.0.21}

RUN apt update -y && apt install -y --no-install-recommends curl supervisor libglib2.0-dev libevent-dev libwim-dev && \
    rm -rf /var/lib/apt/lists/*

RUN curl -kL https://github.com/ventoy/PXE/releases/download/v${IVENTOY_VERSION}/iventoy-${IVENTOY_VERSION}-linux-free.tar.gz -o /tmp/iventoy.tar.gz && \
    tar -xvzf /tmp/iventoy.tar.gz -C /tmp && \
    mv /tmp/iventoy-${IVENTOY_VERSION} /iventoy && \
    mkdir -p /var/log/supervisor && \
    rm -f /tmp/iventoy.tar.gz

COPY files/supervisord.conf /etc/supervisor/supervisord.conf

VOLUME /iventoy/iso /iventoy/data /iventoy/log /iventoy/user

RUN ln -sf /proc/1/fd/1 /iventoy/log/log.txt

EXPOSE 26000 16000 10809 69/udp
ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
