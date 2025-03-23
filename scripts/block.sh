#!/bin/bash
# Block traffic via the emulator

# Get script directory
SCRIPTDIR=$(dirname $(readlink -f $0))

# Include config
. ${SCRIPTDIR}/config.sh

# Binaries
IPTABLES_BIN="/usr/sbin/iptables"

modprobe br_netfilter
echo "1" > /proc/sys/net/bridge/bridge-nf-call-iptables

echo "[INFO] Blocking all traffic ..."

iptables -t filter -A FORWARD -m physdev --physdev-is-bridged -j DROP
