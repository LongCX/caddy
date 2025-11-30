FROM caddy:builder AS builder
RUN xcaddy build \
    --with github.com/caddyserver/transform-encoder \
    --with github.com/porech/caddy-maxmind-geolocation \
    --with github.com/mholt/caddy-ratelimit
RUN mkdir -p /data /config /logs_caddy /other /app

FROM gcr.io/distroless/static:nonroot
COPY --chown=nonroot:nonroot --from=builder /data /app/dt/data
COPY --chown=nonroot:nonroot --from=builder /config /app/dt/config
COPY --chown=nonroot:nonroot --from=builder /logs_caddy /logs_caddy
COPY --chown=nonroot:nonroot --from=builder /other /app/dt/other
COPY --chown=nonroot:nonroot --from=builder /usr/bin/caddy /app/caddy

COPY Caddyfile /etc/caddy/Caddyfile

USER nonroot

ENV XDG_DATA_HOME="/app/dt/data"
ENV XDG_CONFIG_HOME="/app/dt/config"
ENV TZ=Asia/Ho_Chi_Minh

VOLUME ["/app/dt"]

EXPOSE 80 443

ENTRYPOINT ["/app/caddy", "run", "--config", "/etc/caddy/Caddyfile"]
