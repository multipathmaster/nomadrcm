FROM fedora:latest

RUN yum -y update && \
yum -y install bash && \
yum -y install procps-ng && \
yum -y install curl && \
yum -y install jq

ADD dead_man_switch.sh /usr/local/bin/dead_man_switch.sh
ADD nmd_evnt_mntr.sh /usr/local/bin/nmd_evnt_mntr.sh
ADD rocketc_alert.sh /usr/local/bin/rocketc_alert.sh
ADD docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
