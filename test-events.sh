#!/bin/bash

# ----------------README BEGIN----------------
# Make sure that you're running this script as root priviledge. 
# Because not all events can be listed by a non-root user.
# This script will generate two files "compare.csv" and "perf.output"
# "compare.csv" records the output of perf stat for each event
#               Each line represents a single perf stat test. 
#               A group of events are seperated by "---"
#               Count of every event is seperated by ","
#               Note: You can find name of event count in valid_events_hw
# "perf.output" saves perf output as a reference for debug.
# ----------------README END  ----------------

# ----------------VARIABLE BEGIN----------------
WORKDIR=${PWD}
SPECDIR=/home/liyilin/spec2000-all
COMMANDSPEC="runspec --config=x86_64.O0.cfg --input test -n 1 -I -D 252.eon"
VALID_PROMPT="\t\e[32m [valid!] \e[0m"
NOT_VALID_PROMPT="\t\e[31m [not valid!] \e[0m"
# ----------------VARIABLE END  ----------------

function_read_events_from_file(){
    HWEVS="$(cat ${WORKDIR}/valid_events_hw)"
    SWEVS="$(cat ${WORKDIR}/valid_events_sw)"
}

function_test_as_N_groups(){
    cd $SPECDIR
    source $SPECDIR/shrc
    local N="${1}"
    local REPEAT="${2}"
    local LENHW_ALL="$(wc -l ${WORKDIR}/valid_events_hw | awk '{print $1}')"
    local LENHW="$(expr ${LENHW_ALL} / ${N})"
    local LENSW_ALL="$(wc -l ${WORKDIR}/valid_events_sw | awk '{print $1}')"
    local LENSW="$(expr ${LENSW_ALL} / ${N})"
    rm $WORKDIR/compare.csv
    for i in $(seq 1 ${N}); do
        # Hardware event list
        local startline="$(expr ${i} \* ${LENHW} - ${LENHW} + 1)"
        local endline="$(expr ${startline} + ${LENHW} - 1)"
        EVLISTHW=$(sed -n "${startline},${endline}p" ${WORKDIR}/valid_events_hw)
        # Software event list
        local startline="$(expr ${i} \* ${LENSW} - ${LENSW} + 1)"
        local endline="$(expr ${startline} + ${LENSW} - 1)"
        EVLISTSW=$(sed -n "${startline},${endline}p" ${WORKDIR}/valid_events_sw)
        # Append event list
        EVLIST=
        for line in ${EVLISTHW}; do
            if [ "$EVLIST" = "" ]; then
                EVLIST=${line}
            else
                EVLIST="${EVLIST},${line}"
            fi
        done
        for line in ${EVLISTSW}; do
            EVLIST="${EVLIST},${line}"
        done
        # output event names
        echo "${EVLIST}" >> $WORKDIR/compare.csv
        # test by group
        for event in $(echo ${EVLIST} | tr ',' '\n'); do
            perf stat -o $WORKDIR/perf.output -e $event $COMMANDSPEC > /dev/null
            cat $WORKDIR/perf.output | sed -n "6,6p" | awk '{print $1}' | tr '\n' ',' >> $WORKDIR/compare.csv
        done
        echo "" >> $WORKDIR/compare.csv
        for j in $(seq 1 ${REPEAT}); do
            perf stat -o $WORKDIR/perf.output -e $EVLIST $COMMANDSPEC > /dev/null
            cat $WORKDIR/perf.output | sed -n "6,$(expr 6 + ${LENHW} + ${LENSW} - 1)p" | awk '{print $1}' | tr '\n' ',' >> $WORKDIR/compare.csv
            echo "" >> $WORKDIR/compare.csv
        done
        echo "---" >> $WORKDIR/compare.csv
        exit 0 # for test
    done
}


function_read_events_from_file
function_test_as_N_groups "${1}" "${2}" # N_GROUP, REPEAT_N_TIMES