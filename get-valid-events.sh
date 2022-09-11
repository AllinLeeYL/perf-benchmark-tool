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

function_echo_prompt_start(){
    echo -n "Collecting ${1} events." && sleep 1 && echo -n "." && sleep 1 && echo "." && sleep 1
}

function_echo_prompt_end(){
    echo "All valid ${1} perf_events have been saved in ${WORKDIR}/valid_events_hw/sw." && sleep 1
}

function_test_if_valid(){
    # Filter out invalid event for current system
    local COUNT=1
    local LEN=$(echo "${1}" | wc -l)
    VALIDEVS=
    for line in $1
    do
        echo -n "[${COUNT}/${LEN}] " # Show how many have been done
        perf stat -o /dev/null -e ${line} echo -n "${line}" # Test if a event is valid
        if [ $? -eq 0 ]; then
            echo -e "${VALID_PROMPT}"
            VALIDEVS="${line}\n${VALIDEVS}"
        else
            echo -e "${NOT_VALID_PROMPT}"
        fi
        COUNT=$(expr ${COUNT} + 1)
        # ----------for test----------
        # if [ "${COUNT}" = "100" ]; then
        #     break
        # fi
    done
    VALIDEVS="$(echo -e "${VALIDEVS}" | sort | uniq | sed '/^$/d')"
}


function_get_valid_events(){
    EVLIST=$(echo "${EVLIST_DETAIL}" | cut -d\  -f3)
    function_test_if_valid "${EVLIST}"
    # Save valid events as result
    echo -e "$VALIDEVS" > "${WORKDIR}/valid_events_${1}"
    if [ "${1}" = "sw" ]; then
        echo -e "grep -f ${WORKDIR}/valid_events_${2} -v -F -x ${WORKDIR}/valid_events_${1}"
    fi
}

# Hardware events
function_echo_prompt_start "hardware"
EVLIST_DETAIL=$(perf list --no-desc | grep -E "\[(Hardware.*event)|(Kernel PMU event)\]")
function_get_valid_events "hw"
function_echo_prompt_end "hardware"
# Software events
function_echo_prompt_start "software"
EVLIST_DETAIL=$(perf list --no-desc | grep -E "\[.*event\]" | grep -E -v "\[(Hardware.*event)|(Kernel PMU event)\]")
function_get_valid_events "sw" "hw"
function_echo_prompt_end "software"

