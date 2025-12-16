#!/usr/bin/env bash

result_dir=result-hit
disks=$1
threads=16
declare -a depth=("8")
declare -a hitqueue=("32" "96" "125")
hitchhike=1
# Run workloads

for hitSize in "${hitqueue[@]}"; do
    for qd in "${depth[@]}"; do
        # BFS
        ./blaze.py --result_dir ${result_dir} --disks ${disks} --hit ${hitchhike} --queueDepth ${qd} --hitSize ${hitSize} -t ${threads} -k bfs -d rmat27 --start_node 0
        ./blaze.py --result_dir ${result_dir} --disks ${disks} --hit ${hitchhike} --queueDepth ${qd} --hitSize ${hitSize} -t ${threads} -k bfs -d uran27 --start_node 0
        ./blaze.py --result_dir ${result_dir} --disks ${disks} --hit ${hitchhike} --queueDepth ${qd} --hitSize ${hitSize} -t ${threads} -k bfs -d twitter --start_node 12
        ./blaze.py --result_dir ${result_dir} --disks ${disks} --hit ${hitchhike} --queueDepth ${qd} --hitSize ${hitSize} -t ${threads} -k bfs -d sk2005 --start_node 50395005
        ./blaze.py --result_dir ${result_dir} --disks ${disks} --hit ${hitchhike} --queueDepth ${qd} --hitSize ${hitSize} -t ${threads} -k bfs -d friendster --start_node 101
        ./blaze.py --result_dir ${result_dir} --disks ${disks} --hit ${hitchhike} --queueDepth ${qd} --hitSize ${hitSize} -t ${threads} -k bfs -d rmat30 --start_node 0

        # PageRank 
        ./blaze.py --result_dir ${result_dir} --disks ${disks} --hit ${hitchhike} --queueDepth ${qd} --hitSize ${hitSize} -t ${threads} -k pagerank -d rmat27
        ./blaze.py --result_dir ${result_dir} --disks ${disks} --hit ${hitchhike} --queueDepth ${qd} --hitSize ${hitSize} -t ${threads} -k pagerank -d uran27
        ./blaze.py --result_dir ${result_dir} --disks ${disks} --hit ${hitchhike} --queueDepth ${qd} --hitSize ${hitSize} -t ${threads} -k pagerank -d twitter
        ./blaze.py --result_dir ${result_dir} --disks ${disks} --hit ${hitchhike} --queueDepth ${qd} --hitSize ${hitSize} -t ${threads} -k pagerank -d sk2005
        ./blaze.py --result_dir ${result_dir} --disks ${disks} --hit ${hitchhike} --queueDepth ${qd} --hitSize ${hitSize} -t ${threads} -k pagerank -d friendster
        ./blaze.py --result_dir ${result_dir} --disks ${disks} --hit ${hitchhike} --queueDepth ${qd} --hitSize ${hitSize} -t ${threads} -k pagerank -d rmat30

        # # # WCC
        ./blaze.py --result_dir ${result_dir} --disks ${disks} --hit ${hitchhike} --queueDepth ${qd} --hitSize ${hitSize} -t ${threads} -k wcc -d rmat27
        ./blaze.py --result_dir ${result_dir} --disks ${disks} --hit ${hitchhike} --queueDepth ${qd} --hitSize ${hitSize} -t ${threads} -k wcc -d uran27
        ./blaze.py --result_dir ${result_dir} --disks ${disks} --hit ${hitchhike} --queueDepth ${qd} --hitSize ${hitSize} -t ${threads} -k wcc -d twitter
        ./blaze.py --result_dir ${result_dir} --disks ${disks} --hit ${hitchhike} --queueDepth ${qd} --hitSize ${hitSize} -t ${threads} -k wcc -d sk2005
        ./blaze.py --result_dir ${result_dir} --disks ${disks} --hit ${hitchhike} --queueDepth ${qd} --hitSize ${hitSize} -t ${threads} -k wcc -d friendster
        ./blaze.py --result_dir ${result_dir} --disks ${disks} --hit ${hitchhike} --queueDepth ${qd} --hitSize ${hitSize} -t ${threads} -k wcc -d rmat30

        # # # BC
        ./blaze.py --result_dir ${result_dir} --disks ${disks} --hit ${hitchhike} --queueDepth ${qd} --hitSize ${hitSize} -t ${threads} -k bc -d rmat27 --start_node 0
        ./blaze.py --result_dir ${result_dir} --disks ${disks} --hit ${hitchhike} --queueDepth ${qd} --hitSize ${hitSize} -t ${threads} -k bc -d uran27 --start_node 0
        ./blaze.py --result_dir ${result_dir} --disks ${disks} --hit ${hitchhike} --queueDepth ${qd} --hitSize ${hitSize} -t ${threads} -k bc -d twitter --start_node 12
        ./blaze.py --result_dir ${result_dir} --disks ${disks} --hit ${hitchhike} --queueDepth ${qd} --hitSize ${hitSize} -t ${threads} -k bc -d sk2005 --start_node 50395005
        ./blaze.py --result_dir ${result_dir} --disks ${disks} --hit ${hitchhike} --queueDepth ${qd} --hitSize ${hitSize} -t ${threads} -k bc -d friendster --start_node 101
        ./blaze.py --result_dir ${result_dir} --disks ${disks} --hit ${hitchhike} --queueDepth ${qd} --hitSize ${hitSize} -t ${threads} -k bc -d rmat30 --start_node 0

    done
done