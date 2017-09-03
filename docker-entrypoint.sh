#!/bin/bash
# WRITTEN BY MULTIPATHMASTER BECAUSE BASH IS STILL AWESOME
# ENTRYPOINT INTO THE CONTAINER AND MAIN ROOT PID.
# SEE THE -lt 4?  Adjust for how many you have running.
while : ; do
while [[ `ps -ef | grep -i nmd_evnt_mntr | grep -v grep | wc -l` == 0 ]]; do
echo "monitor not running, preparing prime run."
sleep 5
  if [[ `ps -ef | grep -i nmd_evnt_mntr | grep -v grep | wc -l` -lt 4 ]]; then
    for x in `ps -ef | grep -i nmd_evnt_mntr | grep -v grep | awk '{ print $2 }'`; do kill -9 $x; done
    /bin/bash dead_man_switch.sh silent
  else
    echo "Monitors are running, nothing to do here..."
    echo "Continuing next loop..."
  fi
done
done
