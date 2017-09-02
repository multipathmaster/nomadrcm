FROM fedora:latest

RUN yum -y update && \
yum -y install bash && \
yum -y install procps-ng && \
yum -y install curl && \
yum -y install jq

ADD README.TXT /usr/local/bin/README.TXT
ADD dead_man_switch.sh /usr/local/bin/dead_man_switch.sh
ADD nmd_evnt_mntr.sh /usr/local/bin/nmd_evnt_mntr.sh
ADD rocketc_alert.sh /usr/local/bin/rocketc_alert.sh
ADD slack_alert.sh /usr/local/bin/slack_alert.sh
ADD docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

CMD ["/usr/local/bin/docker-entrypoint.sh"]
