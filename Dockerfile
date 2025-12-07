FROM caddy:builder AS builder
RUN xcaddy build \
    --with github.com/caddyserver/transform-encoder \
    --with github.com/LongCX/caddy-ipblock

RUN mkdir -p /data /config /other /app

FROM scratch

COPY --chown=65532:65532 --from=builder /data /app/dt/data
COPY --chown=65532:65532 --from=builder /config /app/dt/config
COPY --chown=65532:65532 --from=builder /other /app/dt/other
COPY --chown=65532:65532 --from=builder /usr/bin/caddy /app/caddy
COPY --chown=65532:65532 Caddyfile /etc/caddy/Caddyfile

USER 65532:65532

ENV XDG_DATA_HOME="/app/dt/data"
ENV XDG_CONFIG_HOME="/app/dt/config"
ENV TZ=Asia/Ho_Chi_Minh

VOLUME ["/app/dt"]

EXPOSE 80 443

ENTRYPOINT ["/app/caddy", "run", "--config", "/etc/caddy/Caddyfile"]
