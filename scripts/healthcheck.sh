#!/usr/bin/env sh

# cron/promtail/unbound-exporter
pgrep -x "crond" > /dev/null || exit 1
pgrep -x "promtail" > /dev/null || exit 1
pgrep -x "unbound-exporter" > /dev/null || exit 1

# redis
redis-cli -s /run/redis/redis.sock ping | grep -q PONG || exit 1

# unbound
drill @127.0.0.1 cloudflare.com > /dev/null || exit 1
