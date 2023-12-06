#!/bin/sh

./test-cluster.sh -p memstore -t 1000 -n 2
./test-cluster.sh -p memstore -t 2000 -n 2
./test-cluster.sh -p memstore -t 4000 -n 2
./test-cluster.sh -p rocksdb -t 1 -n 2
./test-cluster.sh -p rocksdb -t 2 -n 2
./test-cluster.sh -p rocksdb -t 3 -n 2

./test-cluster.sh -p memstore -t 1000 -n 4
./test-cluster.sh -p memstore -t 2000 -n 4
./test-cluster.sh -p memstore -t 4000 -n 4
./test-cluster.sh -p rocksdb -t 1 -n 4
./test-cluster.sh -p rocksdb -t 2 -n 4
./test-cluster.sh -p rocksdb -t 3 -n 4

./test-cluster.sh -p memstore -t 1000 -n 8
./test-cluster.sh -p memstore -t 2000 -n 8
./test-cluster.sh -p memstore -t 4000 -n 8
./test-cluster.sh -p rocksdb -t 1 -n 8
./test-cluster.sh -p rocksdb -t 2 -n 8
./test-cluster.sh -p rocksdb -t 3 -n 8

./test-cluster.sh -p memstore -t 1000 -n 16
./test-cluster.sh -p memstore -t 2000 -n 16
./test-cluster.sh -p memstore -t 4000 -n 16
./test-cluster.sh -p rocksdb -t 1 -n 16
./test-cluster.sh -p rocksdb -t 2 -n 16
./test-cluster.sh -p rocksdb -t 3 -n 16
