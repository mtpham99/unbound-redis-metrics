# Unbound-Redis-Metrics

Dockerfile to build a container image for running [Unbound DNS](https://www.nlnetlabs.nl/projects/unbound/about/) using [Redis](https://redis.io/) as a cache database. Also includes a [metrics exporter](https://github.com/ar51an/unbound-exporter) for [Prometheus](https://prometheus.io/) and [Loki/Promtail log scraper](https://github.com/ar51an/unbound-dashboard) for usage with [ar51an's grafana unbound-dashboard](https://github.com/ar51an/unbound-dashboard).

[Unbound DNS dashboard](https://github.com/ar51an/unbound-dashboard) is separate and available [here](https://github.com/ar51an/unbound-dashboard).

All credit for the [Unbound dashboard](https://github.com/ar51an/unbound-dashboard), [Prometheus metrics exporter](https://github.com/ar51an/unbound-exporter), and [Loki/Promtail config](https://github.com/ar51an/unbound-dashboard)] goes to [@Ar51an](https://github.com/ar51an).

## Required Environment Variables

- **LOKI_ADDRESS**: address of Loki server (e.g. "localhost:3100")

## Domain Blocklists

- List of blocklists located at `/etc/unbound.d/blocklist_urls.txt`

    - One blocklist URL on each line

    - Blocklist should use "host" formatting

    - Cronjob refreshes blocklists everyday at midnight

    - Default list contains 2 blocklists:

        1. [Hagezi's Ultimate Blocklist](https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/hosts/ultimate.txt)

        2. [StevenBlack's List](https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts)

## Ports

- **53/tcp/udp**: unbound dns

- **9167/tcp**: prometheus metrics endpoint

## Cronjobs

1. Blocklists updated everyday at midnight ([here](/scripts/update_blocklist.sh))

2. Root hints updated at midnight on first day of each month ([here](/scripts/update_roothints.sh))

## Runtime Directories

- `/run/unbound`: unbound.sock, unbound.pid, root.hints, root.key

- `/run/redis`: redis.sock, redis.pid, dump.rdb

## Log Directories

- `/var/log/unbound`

- `/var/log/redis`

- `/var/log/promtail`

- `/var/log/cron`


## Info Links

1. [Ar51an's Unbound Dashboard](https://github.com/ar51an/unbound-dashboard)
2. [Ar51an's Unbound Exporter](https://github.com/ar51an/unbound-exporter)
3. [Unbound DNS Optimization](https://web.archive.org/web/20180508133447/https://unbound.net/documentation/howto_optimise.html)
4. [Unbound DNS "Adblocking"](https://github.com/Antonius-git/unbound-adblocking)
5. [Unbound DNS Configuration](https://unbound.docs.nlnetlabs.nl/en/latest/manpages/unbound.conf.html)
6. [Redis Configuration](https://redis.io/docs/latest/operate/oss_and_stack/management/config/)
