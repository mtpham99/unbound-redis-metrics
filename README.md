# Unbound-Redis-Metrics

Dockerfile to build a container image for running [unbound dns](https://www.nlnetlabs.nl/projects/unbound/about/) using [redis](https://redis.io/) as a cache database. Also includes a [prometheus](https://prometheus.io/) exporter and [promtail/loki](https://grafana.com/docs/loki/latest/) log scraper written by [ar51an](https://github.com/ar51an) for usage with [ar51an's grafana unbound-dashboard](https://github.com/ar51an/unbound-dashboard).


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
