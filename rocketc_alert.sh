#!/bin/bash
#WRITTEN BY MULTIPATHMASTER BECAUSE BASH IS STILL AWESOME
#CREATE A NEW USER HASH AND TOKEN BY LOGGING IN AND COLLECTING THIS INFORMATION
#USE IT TO GENERATE AN ALERT
#THEN DESTROY THE EVIDENCE
#FEEL FREE TO WRITE YOUR OWN HTTPS/AUTH/SSL STANDARDS INSTEAD OF A STRAIGHT USER/PASS COMBO

#PUT YOUR RC SERVER AND PORT HERE
SERV="${RC_SVR_PRT}"

#PUT YOUR NOMAD SERVER AND PATH VAR USE HASHI-UI ATM
NSERV="${NOMAD_SRV_JOB_PATH}"

#PUT YOUR AUTH STUFF HERE, IF YOU HAVE VAULT, I SALUTE YOU
AUTH="${RC_AUTH}"

#TOKEN TYPE
TT="X-Auth-Token"

#X USER ID
XUI="X-User-Id"

#CONTENT SELECTOR
CS="Content-type"

#CONTENT TYPE
CONT="application/json"

#WHAT TYPE OF ALERT WILL NMD_EVNT_MNTR SEND TO THIS TOOL?
TYPE=$1

debugger(){
set -x
}

#TAKE THIS OUT HOWEVER YOU SEE FIT OR IF YOU WANT PERM AUTH, COMMENT OUT THIS RUN BELOW IN THE MAIN SECTION
#HOWEVER NOTE YOU WILL HAVE TO MODIFY THE X-Auth-Token and X-User-Id FIELDS WITHIN THE CURL POST
generate_new_token(){
curl -s ${SERV}/api/v1/login -d ${AUTH} | jq -r '' | egrep '(authToken|userId)' | sed s/\ //g | awk -F "\"" '{ print $4 }' > rocketcauth.$$
}

view_tokens(){
cat rocketcauth.$$
}

#DONT TOUCH/MODIFY SPACING, ITLLLLLL BREAK, YOUVE BEEN WARNED
alerting(){
if [[ ${TYPE} == zombie ]]; then
AUTHT=`cat rocketcauth.$$ | head -1`
USRHSH=`cat rocketcauth.$$ | tail -1`

curl -s -H "${TT}: ${AUTHT}"      -H "${XUI}: ${USRHSH}"      -H "${CS}:${CONT}"      ${SERV}/api/v1/chat.postMessage      -d '{ "channel": "#general", "text": "Zombies!" }'
elif [[ ${TYPE} == failed ]]; then
AUTHT=`cat rocketcauth.$$ | head -1`
USRHSH=`cat rocketcauth.$$ | tail -1`

curl -s -H "${TT}: ${AUTHT}"      -H "${XUI}: ${USRHSH}"      -H "${CS}:${CONT}"      ${SERV}/api/v1/chat.postMessage      -d '{ "channel": "#general", "text": ":robot: ALERT: [FAILED JOBS]('$(echo ${NSERV})')! :fire:" }'
elif [[ ${TYPE} == lost ]]; then
AUTHT=`cat rocketcauth.$$ | head -1`
USRHSH=`cat rocketcauth.$$ | tail -1`

curl -s -H "${TT}: ${AUTHT}"      -H "${XUI}: ${USRHSH}"      -H "${CS}:${CONT}"      ${SERV}/api/v1/chat.postMessage      -d '{ "channel": "#general", "text": ":robot: ALERT: [LOST JOBS]('$(echo ${NSERV})')! :fire:" }'
elif [[ ${TYPE} == running ]]; then
AUTHT=`cat rocketcauth.$$ | head -1`
USRHSH=`cat rocketcauth.$$ | tail -1`

curl -s -H "${TT}: ${AUTHT}"      -H "${XUI}: ${USRHSH}"      -H "${CS}:${CONT}"      ${SERV}/api/v1/chat.postMessage      -d '{ "channel": "#general", "text": ":robot: ALERT: [NO RUNNING JOBS]('$(echo ${NSERV})')! :fire:" }'
elif [[ ${TYPE} == queued ]]; then
AUTHT=`cat rocketcauth.$$ | head -1`
USRHSH=`cat rocketcauth.$$ | tail -1`

curl -s -H "${TT}: ${AUTHT}"      -H "${XUI}: ${USRHSH}"      -H "${CS}:${CONT}"      ${SERV}/api/v1/chat.postMessage      -d '{ "channel": "#general", "text": ":robot: ALERT: [QUEUED JOBS]('$(echo ${NSERV})')! :fire:" }'
else
  echo "Unsupported TYPE detected."
fi
}

#CLEANUP THE CRIME SCENE
cleanup(){
rm -rf rocketcauth.$$
}

main(){
generate_new_token
#view_tokens
alerting $@
cleanup
}

#debugger
main $@
