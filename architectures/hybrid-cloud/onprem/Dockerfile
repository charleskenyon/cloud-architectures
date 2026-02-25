FROM alpine:3

RUN apk add --no-cache \
    strongswan \
    iproute2 \
    iptables \
    bash \
    tcpdump \
    gettext \
    bind \
    bind-tools

COPY start.sh /start.sh
COPY templates /templates

RUN chmod +x ./start.sh

CMD ["./start.sh"]