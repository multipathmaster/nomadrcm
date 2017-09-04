#!/bin/bash
#WRITTEN BY MULTIPATHMASTER
#THE DEAD MAN SWITCH FOR EVENT MONITORING IN RC/SLACK
#THE IDEA: SET A TRAP TO LOOK FOR KEY EVENTS THAT SHOULD BE ADDRESSED.
#ALERT THESE IN RC/SLACK.  THEN RE-SET THE TRAP AND AWAIT FOR ANOTHER EVENT
#I FOUND THAT THESE 4 SEEM TO ALERT ME WHEN THINGS GO BAD BEFORE SPLUNK OR OTHER STATSD STUFF.
#VAR

TYPE=$1

debugger(){
set -x
}

#COMMENT OUT THE ONES YOU DONT WISH TO RUN
egon_the_silent_trap(){
/bin/bash nmd_evnt_mntr.sh queued > /dev/null 2>&1 &
/bin/bash nmd_evnt_mntr.sh lost > /dev/null 2>&1 &
/bin/bash nmd_evnt_mntr.sh failed > /dev/null 2>&1 &
/bin/bash nmd_evnt_mntr.sh running > /dev/null 2>&1 &
#/bin/bash nmd_evnt_mntr.sh starting > /dev/null 2>&1 &
#/bin/bash nmd_evnt_mntr.sh complete > /dev/null 2>&1 &
}

#COMMENT OUT THE ONES YOU DONT WISH TO RUN
peter_the_loud_trap(){
/bin/bash nmd_evnt_mntr.sh queued &
/bin/bash nmd_evnt_mntr.sh lost &
/bin/bash nmd_evnt_mntr.sh failed &
/bin/bash nmd_evnt_mntr.sh running &
#/bin/bash nmd_evnt_mntr.sh starting &
#/bin/bash nmd_evnt_mntr.sh complete &
}

#DEAD MAN SWITCH TO KILL THE PIDS
winston_the_killer(){
for x in `ps -ef | grep nmd_evnt_mntr | grep -v grep | awk '{ print $2 }'`; do kill -9 $x; done
}

#ADJUST TO ONE LESS THAN YOU HAVE RUNNING
ray_the_talker(){
if [[ `ps -ef | grep nmd_evnt_mntr | grep -v grep | wc -l` -gt 3 ]]; then
  echo "The Monitor is Running..."
else
  echo "The Monitor is Not Running..."
fi
}

main(){
if [[ ${TYPE} == loud ]]; then
  peter_the_loud_trap
elif [[ ${TYPE} == silent ]]; then
  egon_the_silent_trap
elif [[ ${TYPE} == kill ]]; then
  winston_the_killer
elif [[ ${TYPE} == talk ]]; then
  ray_the_talker
else
  echo "Unsupported TYPE argument, valid args are loud silent talk and kill."
fi
}

debugger
main $@
