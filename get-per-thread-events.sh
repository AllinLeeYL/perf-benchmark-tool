#!/bin/bash

# ----------------README BEGIN----------------
# Make sure that you're running this script as root priviledge. 
# Because not all events can be listed by a non-root user.
# ----------------README END  ----------------

# ----------------VARIABLE BEGIN----------------
WORKDIR=${PWD}
VALID_PROMPT="\t\e[32m [valid!] \e[0m"
NOT_VALID_PROMPT="\t\e[31m [not valid!] \e[0m"
# ----------------VARIABLE END  ----------------

EVLIST=
RAW=$(cat ${WORKDIR}/valid_events_hw)
for line in $RAW; do
    perf stat -o ${WORKDIR}/perf.output -e ${line},branch-instructions echo -n "${line}"
    count=$(cat ${WORKDIR}/perf.output | sed -n "6,6p" | awk '{print $1}')
    if [ "$count" != "<not" ]; then
        EVLIST="${line}\n${EVLIST}"
        echo -e "${VALID_PROMPT}"
    else
        echo -e "${NOT_VALID_PROMPT}"
    fi
    echo -e ${EVLIST} > ${WORKDIR}/per-thread-events_hw
done