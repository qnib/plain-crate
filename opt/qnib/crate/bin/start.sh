#!/bin/bash

crate \
    -Des.discovery.zen.ping.unicast.hosts=crate_db \
    -Des.gateway.expected_nodes=${CRATE_EXP_NODES:-1} \
    -Des.discovery.zen.minimum_master_nodes=1 \
    -Des.gateway.recover_after_nodes=1  \
    -Des.network.bind=_eth0:ipv4_

