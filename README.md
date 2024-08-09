# unbound-redis-metrics

Dockerfile to build a container image to run [unbound dns](https://www.nlnetlabs.nl/projects/unbound/about/) using [redis](https://redis.io/) as a cache database. Also includes a [prometheus](https://prometheus.io/) exporter and [promtail/loki](https://grafana.com/docs/loki/latest/) log scraper written by [ar51an](https://github.com/ar51an).


## Default Configs

- Loki address specified via "LOKI_ADDRESS" environment variable

- Runs the redis server with access exclusively through a unix socket (i.e. no tcp connections) and has unbound connect via the socket.

- List of blocklists (single url on each line to a blocklist in "host" format) located at /etc/unbound.d/blocklist_urls.txt. By default contains 2 lists: [Hagezi's Ultimate Blocklist](https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/hosts/ultimate.txt) and [StevenBlack's List](https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts)

- Cronjob for updating blocklists and root anchor/hints.

- Ports:

    - 53/tcp/udp: unbound dns

    - 9167/tcp: unbound-exporter metrics

- Logs to various directories in /var/log

- Runtime dirs:

    - /run/unbound: unbound.sock, unbound.pid, root.hints, root.key

    - /run/redis: redis.sock, redis.pid, dump.rdb



## Info Links

1. [Ar51an's Unbound Dashboard](https://github.com/ar51an/unbound-dashboard)
2. [Ar51an's Unbound Exporter](https://github.com/ar51an/unbound-exporter)
3. [Unbound DNS Optimization](https://web.archive.org/web/20180508133447/https://unbound.net/documentation/howto_optimise.html)
4. [Unbound DNS "Adblocking"](https://github.com/Antonius-git/unbound-adblocking)
5. [Unbound DNS Configuration](https://unbound.docs.nlnetlabs.nl/en/latest/manpages/unbound.conf.html)
