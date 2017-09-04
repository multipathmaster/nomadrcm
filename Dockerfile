FROM gliderlabs/alpine:3.4

RUN apk add --no-cache bash curl jq

ADD dead_man_switch.sh /usr/local/bin/dead_man_switch.sh
ADD nmd_evnt_mntr.sh /usr/local/bin/nmd_evnt_mntr.sh
ADD rocketc_alert.sh /usr/local/bin/rocketc_alert.sh
ADD docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
