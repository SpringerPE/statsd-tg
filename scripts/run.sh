#!/bin/bash -e

RETAIN_NUM_LINES=100
LOGFILE=statsd-tg.log

#Frequency of the generated events 1 / $scale microseconds
SCALE="10000 1000 100 10"
DURATION=120

function logsetup {
    TMP=$(tail -n $RETAIN_NUM_LINES $LOGFILE 2>/dev/null) && echo "${TMP}" > $LOGFILE
    exec > >(tee -a $LOGFILE)
    exec 2>&1
}

function log {
    echo "[$(date)]: $*"
}


logsetup

for scale in $SCALE; do

log ###############################
log START scale factor $scale

# RETURNS 124 when it times out
set +e
timeout ${DURATION}s statsd-tg -p $scale -d 10.230.35.189 -D 8125
if [ "$?" -ne "124" ]; then log "statsd-tg failed"; exit 1; fi
set -e

log STOP scale factor $scale
log ###############################

done
