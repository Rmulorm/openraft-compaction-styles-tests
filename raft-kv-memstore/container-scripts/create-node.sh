#!/bin/sh

LOG_FILE=./logs/node_${NODE_ID}.log
DSTAT_FILE=./logs/dstat_report_${NODE_ID}.csv

handler()
{
  echo "Stopping container"
  kill -9 $RAFT_PID
  echo "Raft stoped"
  sleep 5
  kill -9 $DSTAT_PID
  echo "dstat stoped"
  exit
}

nohup ./container-scripts/start-pmcd.sh > /dev/null &
sleep 5

echo "Starting Raft"
pcp dstat --time --cpu --mem --disk --net --load --output ${DSTAT_FILE} &
DSTAT_PID=$!
raft-key-value --id ${NODE_ID} --http-addr 0.0.0.0:21000 --snapshot-target ${SNAPSHOT_TARGET} > ${LOG_FILE} &
RAFT_PID=$!

echo "Raft Node ${NODE_ID} Running"

trap handler TERM

while true; do
    sleep 1
done