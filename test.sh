#!/bin/bash

# ----------------------------------Define Begin----------------------------------
# Available events file
EVENTSF=/home/liyilin/perf-benchmark-tool/valid_events_hw
# Define working directory
PERFDIR=/home/liyilin/perf-benchmark-tool
SPECDIR=/home/liyilin/spec2000-all
# Define events list
EVLIST=""
# Define benchmark to run
COMMANDSPEC="runspec --config=x86_64.O0.cfg --input test -n 1 -I -D 252.eon"
# ----------------------------------Define End  ----------------------------------


cd $SPECDIR
source $SPECDIR/shrc

if [ "$1" = "events" ]; then
    for line in $(sed -n "1,30p" $EVENTSF)
    do
        if [ "$EVLIST" = "" ]; then
            EVLIST=${line}
        else
            EVLIST="${EVLIST},${line}"
        fi
    done
    # echo $EVLIST
    perf stat -o $PERFDIR/perf.output -e ${EVLIST} $COMMANDSPEC
    # perf record -e $EVLIST -R -o $PERFDIR/perf.data $COMMANDSPEC
    chown liyilin:liyilin $PERFDIR/perf.data
    rm $SPECDIR/result/*
elif [ "$1" = "filter" ]; then
    ${PERFDIR}/runnable_list-v2.txt
    for line in $(cat $EVENTSF)
    do
        perf stat -e ${line} ls
        if [ $? -eq 0 ]; then
            echo "${line}" >> ${PERFDIR}/runnable_list-v2.txt
        fi
        # EVLIST="${EVLIST},${line}"
    done
else
    # perf record -e \{cpu-cycles:P,instructions:P,cache-misses,cache-references\} -o $PERFDIR/perf.data $COMMANDSPEC
    perf stat -e r00c5,r00c4,r013c,r4f2e $COMMANDSPEC
    # perf stat -e r00c5,r00c4,r013c,r4f2e,r412e,cpu-cycles,branch-misses,context-switches,cache-misses,branch-loads,cache-references,branches,instructions $COMMANDSPEC
    # perf stat -e \{cpu-cycles:P,instructions:P,cache-misses,cache-references\} $COMMANDSPEC
    chown liyilin:liyilin $PERFDIR/perf.data
    rm $SPECDIR/result/*
fi

# branches (default sample rate): 
# 1   :           27979493147
# 1   (record):   27824150572, samples:180K
# 1-3 :           27981139708
# 1-3 (record):   27995099321, samples:195K
# 1-20(record):   19119589547, samples:131K
# 1-30(record):    5241047350, samples: 42K
# 1-60:           26795596295
# 1-200:          26301484115
# 1-300:          96300571700   633.592 M/sec
# 1-300:          100336440616  672.221 M/sec
# Event count (approx.): 242569774794

# page-faults:
# 1           :   1704111
# 1-60        :   1704084
# 1-300       :   1703961
# 1-600       :   1704233, 1704009

# 19000919
# 42692100
# 18410852