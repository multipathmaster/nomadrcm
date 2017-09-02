#!/bin/bash
#WRITTEN BY MULTIPATHMASTER BECAUSE BASH IS STILL AWESOME
#I understand these backticks are terrible looking, but understand you need to gather/query the actual shit from nomad in order to track it.
#The idea here is that this is the master 'golf club' so to speak, but many players will be using it at the same time, so we will introduce arguments.
#The arguments will be different calls to different until loops, and teh idea is to do a rc/slack post with the one that alerted at time of alert

#VARS
#PUT YOUR NOMAD IP/HOSTNAME HERE
SERV="http://NOMAD_IP_HOSTNAME:4646/v1/jobs"

debugger(){
set -x
}

#THIS GETS CALLED UPON BY THE DEAD_MAN_SWITCH AND FEEDS THE ARGUMENTS CONFIGURED PER MONITORING TYPE
TYPE=$1

#HOW THESE WORK:  A SIMPLE GET FROM NOMAD API FRONTEND, SOME FILTERING W/ JQ
#SOME GREPS AND OTHER NEFARIOUS THINGS TO GATHER OVERALL JOB STATUS
#IF AN ALERT MATCHES IT GOES INSIDE AN INTERNAL WHILE LOOP, AND AS LONG
#AS IT STILL MATCHES THE CONDITION, WILL ALERT EVERY 5 MINUTES
#THE ECHO STATMENTS ARE MEANINGFUL IF YOU RUN DEADMAN WITH LOUD ARGUMENT

queued_checker(){
#RUN UNTIL I SEE A QUEUED JOB
until [[ `curl -s -X GET ${SERV} | jq -r '.[] | {Name, Status: .JobSummary.Summary}' | grep "Queued" | grep 1 | wc -l` -ne 0 ]]; do
echo "INFO: Not Detecting..."
echo "INFO: Sleeping..."
#HOW FAST WE ARE CHECKING FOR THE CONDITION
sleep 1
  #LOUD ALERTING TYPE
  if [[ `curl -s -X GET ${SERV} | jq -r '.[] | {Name, Status: .JobSummary.Summary}' | grep "Queued" | grep 1 | wc -l` -gt 0 ]]; then
    echo "ALERT: ALERTING, BREAKING LOOP TO ALERT. THERE ARE QUEUED JOBS."
    #SHIFT INTO SILENT/LOUD ALERTING MECHANISM
    while [[ `curl -s -X GET ${SERV} | jq -r '.[] | {Name, Status: .JobSummary.Summary}' | grep "Queued" | grep 1 | wc -l` -gt 0 ]]; do
      #RC/SLACK POST GOES HERE
      /usr/local/bin/rocketc_alert.sh queued
      sleep 300
    done
  else
    #ONCE THE CONDITION IS FIXED, BREAK OUT INTO THIS UNTIL LOOP TO PREPARE FOR THE NEXT LOOP
    echo "INFO: Everything normal in sub loop checker Queued."
    echo "INFO: Loop Phase..."
  fi
done
}

failed_checker(){
until [[ `curl -s -X GET ${SERV} | jq -r '.[] | {Name, Status: .JobSummary.Summary}' | grep "Failed" | grep 1 | wc -l` -ne 0 ]]; do
echo "INFO: Not Detecting..."
echo "INFO: Sleeping..."
sleep 1
  if [[ `curl -s -X GET ${SERV} | jq -r '.[] | {Name, Status: .JobSummary.Summary}' | grep "Failed" | grep 1 | wc -l` -gt 0 ]]; then
    echo "ALERT: ALERTING, BREAKING LOOP TO ALERT. THERE ARE FAILED JOBS."
    while [[ `curl -s -X GET ${SERV} | jq -r '.[] | {Name, Status: .JobSummary.Summary}' | grep "Failed" | grep 1 | wc -l` -gt 0 ]]; do
      /usr/local/bin/rocketc_alert.sh failed
      sleep 300
    done
  else
    echo "INFO: Everything normal in sub loop checker Failed."
    echo "INFO: Next Loop Phase..."
  fi
done
}

starting_checker(){
until [[ `curl -s -X GET ${SERV} | jq -r '.[] | {Name, Status: .JobSummary.Summary}' | grep "Starting" | grep 1 | wc -l` -ne 0 ]]; do
echo "INFO: Not Detecting..."
echo "INFO: Sleeping..."
sleep 1
  if [[ `curl -s -X GET ${SERV} | jq -r '.[] | {Name, Status: .JobSummary.Summary}' | grep "Starting" | grep 1 | wc -l` -ne 0 ]]; then
    echo "ALERT: ALERTING, BREAKING LOOP TO ALERT."
    break
  else
    echo "INFO: Everything normal in sub loop checker..."
    echo "INFO: Next Loop Phase..."
  fi
done
}

lost_checker(){
until [[ `curl -s -X GET ${SERV} | jq -r '.[] | {Name, Status: .JobSummary.Summary}' | grep "Lost" | grep 1 | wc -l` -ne 0 ]]; do
echo "INFO: Not Detecting..."
echo "INFO: Sleeping..."
sleep 1
  if [[ `curl -s -X GET ${SERV} | jq -r '.[] | {Name, Status: .JobSummary.Summary}' | grep "Lost" | grep 1 | wc -l` -gt 0 ]]; then
    echo "ALERT: ALERTING, BREAKING LOOP TO ALERT. THERE ARE LOST JOBS."
    while [[ `curl -s -X GET ${SERV} | jq -r '.[] | {Name, Status: .JobSummary.Summary}' | grep "Lost" | grep 1 | wc -l` -gt 0 ]]; do
      /usr/local/bin/rocketc_alert.sh lost
      sleep 300
    done
  else
    echo "INFO: Everything normal in sub loop checker Lost."
    echo "INFO: Next Loop Phase..."
  fi
done
}

complete_checker(){
until [[ `curl -s -X GET ${SERV} | jq -r '.[] | {Name, Status: .JobSummary.Summary}' | grep "Complete" | grep 1 | wc -l` -ne 0 ]]; do
echo "INFO: Not Detecting..."
echo "INFO: Sleeping..."
sleep 1
  if [[ `curl -s -X GET ${SERV} | jq -r '.[] | {Name, Status: .JobSummary.Summary}' | grep "Complete" | grep 1 | wc -l` -ne 0 ]]; then
    echo "ALERT: ALERTING, BREAKING LOOP TO ALERT."
    break
  else
    echo "INFO: Everything normal in sub loop checker..."
    echo "INFO: Next Loop Phase..."
  fi
done
}

running_checker(){
until [[ `curl -s -X GET ${SERV} | jq -r '.[] | {Name, Status: .JobSummary.Summary}' | grep "Running" | grep 1 | wc -l` == 0 ]]; do
echo "INFO: Not Detecting..."
echo "INFO: Sleeping..."
sleep 1
  if [[ `curl -s -X GET ${SERV} | jq -r '.[] | {Name, Status: .JobSummary.Summary}' | grep "Running" | grep 1 | wc -l` == 0 ]]; then
    echo "ALERT: ALERTING, THERE ARE NO RUNNING JOBS."
    while [[ `curl -s -X GET ${SERV} | jq -r '.[] | {Name, Status: .JobSummary.Summary}' | grep "Running" | grep 1 | wc -l` == 0 ]]; do
      /usr/local/bin/rocketc_alert.sh running
      sleep 300
    done
  else
    echo "INFO: Everything normal in sub loop checker Running."
    echo "INFO: Next Loop Phase..."
  fi
done
}

#HERE WE ARE CALLING UPON THE DIFFERNT TYPES TO SPAWN DIFFERENT PIDS
#FEEL FREE TO ADD MORE TYPES AND OTHER CURLS TO THE INTERFACE
#TRIED TO MAKE THIS AS CAVEMAN TO THE 'NIX USER AS POSSIBLE
#DEADMAN CALLS THIS HENCE THE EXIT 187 IN THE ELSE
main(){
if [[ ${TYPE} == "queued" ]]; then
  queued_checker
elif [[ ${TYPE} == "failed" ]]; then
  failed_checker
elif [[  ${TYPE} == "running" ]]; then
  running_checker
elif [[ ${TYPE} == "starting" ]]; then
  starting_checker
elif [[ ${TYPE} == "lost" ]]; then
  lost_checker
elif [[ ${TYPE} == "complete" ]]; then
  complete_checker
else
  echo "Unsure WTF just happened."
  exit 187
fi
}

#debugger
main $@
