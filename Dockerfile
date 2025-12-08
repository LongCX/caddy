FROM caddy:builder AS builder
RUN xcaddy build \
    --with github.com/caddyserver/transform-encoder \
    --with github.com/LongCX/caddy-ipblock

RUN mkdir -p /data /config /other /app

FROM alpine:latest AS tz
RUN apk add --no-cache tzdata

# Health
FROM 11notes/distroless:localhealth AS distroless-localhealth

FROM scratch
COPY --chown=65532:65532 --from=builder /data /app/dt/data
COPY --chown=65532:65532 --from=builder /config /app/dt/config
COPY --chown=65532:65532 --from=builder /other /app/dt/other
COPY --chown=65532:65532 --from=builder /usr/bin/caddy /app/caddy
COPY --chown=65532:65532 Caddyfile /etc/caddy/Caddyfile
COPY --chown=65532:65532 --from=tz /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime
COPY --chown=65532:65532 --from=distroless-localhealth / /

ENV XDG_DATA_HOME="/app/dt/data"
ENV XDG_CONFIG_HOME="/app/dt/config"

VOLUME ["/app/dt"]

EXPOSE 80 443

HEALTHCHECK --interval=15s --timeout=2s --start-period=5s \
  CMD ["/usr/local/bin/localhealth", "http://127.0.0.1:80/health"]

USER 65532:65532

ENTRYPOINT ["/app/caddy", "run", "--config", "/etc/caddy/Caddyfile"]
