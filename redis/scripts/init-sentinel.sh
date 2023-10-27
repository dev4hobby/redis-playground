#!/bin/sh

sed -i "s/\$SENTINEL_QUORUM/$SENTINEL_QUORUM/g" /d3fau1t/etc/conf/common.conf
sed -i "s/\$SENTINEL_DOWN_AFTER/$SENTINEL_DOWN_AFTER/g" /d3fau1t/etc/conf/common.conf
sed -i "s/\$SENTINEL_FAILOVER/$SENTINEL_FAILOVER/g" /d3fau1t/etc/conf/common.conf

redis-server /d3fau1t/etc/conf/common.conf --sentinel
