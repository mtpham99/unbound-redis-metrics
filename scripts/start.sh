#!/usr/bin/env sh

# check for required env vars
if [ -z "$LOKI_ADDRESS" ]; then
   echo 'Error: "LOKI_ADDRESS" env var not set!'
   exit 1
fi

# create log dirs
mkdir -p /var/log/unbound /var/log/redis /var/log/promtail /var/log/cron
chown -R unbound:unbound /var/log/unbound
chown -R redis:redis /var/log/redis
chown -R promtail:promtail /var/log/promtail

# start cron daemon for updating blocklist and root anchor
crond -b -l 5 -L /var/log/cron/cron.log

# start redis db
su -s /bin/sh -c 'redis-server /etc/redis.conf' redis &

# wait for redis to create socket to change ownership
sleep 10
chown redis:unbound-redis /run/redis/redis.sock

# start unbound exporter
su -s /bin/sh \
   -c 'unbound-exporter --block-file /etc/unbound.d/blocklist.conf \
                        --web.listen-address 0.0.0.0:9167 \
                        --web.metrics-path /metrics \
                        --unbound.uri unix:///run/unbound/unbound.sock' \
   unbound &

# start promtail
su -s /bin/sh -c 'promtail -config.expand-env=true -config.file=/etc/promtail/unbound_exporter.yaml >> /var/log/promtail/promtail.log 2>&1' promtail &

# start unbound dns
unbound -d -c /etc/unbound.conf
