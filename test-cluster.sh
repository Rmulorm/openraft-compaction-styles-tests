#!/bin/sh

set -o errexit

rpc() {
    local uri=$1
    local body="$2"

    echo '---'" rpc(:$uri, $body)"

    {
        if [ ".$body" = "." ]; then
            time curl --silent "127.0.0.1:$uri"
        else
            time curl --silent "127.0.0.1:$uri" -H "Content-Type: application/json" -d "$body"
        fi
    } | {
        if type jq > /dev/null 2>&1; then
            jq
        else
            cat
        fi  
    }

    echo
}

while getopts "p:t:n:" option; do
    case "$option" in
        p) PROJECT=${OPTARG};;
        t) TARGET=${OPTARG};;
        n) CLIENTS_NUM=${OPTARG};;
    esac
done

if [[ ${PROJECT} = 'rocksdb' ]]; then
    case ${TARGET} in
        1)
            TARGET_NAME="Fifo"
            ;;
        2)
            TARGET_NAME="Level"
            ;;
        3)
            TARGET_NAME="Universal"
            ;;
        *)
            TARGET_NAME="Universal"
            ;;
    esac
else
    TARGET_NAME=${TARGET}
fi

export RUST_LOG=trace
export TEST_PROJECT_NAME=raft-kv-${PROJECT}

echo "###### Testing ${TEST_PROJECT_NAME} with target ${TARGET_NAME} and ${CLIENTS_NUM} clients ######"
echo "Killing all running raft-key-value"

docker compose -f ${TEST_PROJECT_NAME}/docker-compose.yml -p ${TEST_PROJECT_NAME} stop
# rm ./text-logs.txt
rm -rf ./node-logs/*
rm -rf ./tests/*

sleep 1

echo "Start 3 uninitialized raft-key-value servers with Snapshot Target as ${TARGET}..."
docker compose -f ${TEST_PROJECT_NAME}/docker-compose.yml -p ${TEST_PROJECT_NAME}  up -d
sleep 20

echo "Initialize server 1 as a single-node cluster"
echo
rpc 21001/init '{}'
sleep 3
echo "Server 1 is a leader now"

echo "Adding node 2 and node 3 as learners, to receive log from leader node 1"
echo
rpc 21001/add-learner       '[2, "node-2:21000"]'
echo "Node 2 added as learner"
sleep 3
echo
rpc 21001/add-learner       '[3, "node-3:21000"]'
echo "Node 3 added as learner"
sleep 3

echo "Changing membership from [1] to 3 nodes cluster: [1, 2, 3]"
echo
rpc 21001/change-membership '[1, 2, 3]'
echo 'Membership changed to [1, 2, 3]'
sleep 3

export JMETER_CONFIG_FILE=./jmeter-config-${CLIENTS_NUM}.jmx
echo "Starting load test with ${JMETER_CONFIG_FILE} at"
date
jmeter -n -t ${JMETER_CONFIG_FILE} -l ./tests/test-result.txt -e -o ./tests/result

export RESULTS_DIR=~/study/tcc/test-results/${PROJECT}-${TARGET_NAME}-${CLIENTS_NUM}
mkdir -p ${RESULTS_DIR}
cp ./node-logs/* ${RESULTS_DIR}
cp -r ./tests/* ${RESULTS_DIR}

echo "Finishing test..."
docker compose -f ${TEST_PROJECT_NAME}/docker-compose.yml -p ${TEST_PROJECT_NAME} stop
