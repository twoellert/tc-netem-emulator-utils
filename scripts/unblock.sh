#!/bin/bash
# Unblock traffic via the emulator

# Get script directory
SCRIPTDIR=$(dirname $(readlink -f $0))

# Include config
. ${SCRIPTDIR}/config.sh

# Binaries
IPTABLES_BIN="/usr/sbin/iptables"

# Make sure proper module is loaded
modprobe br_netfilter
echo "1" > /proc/sys/net/bridge/bridge-nf-call-iptables

echo "[INFO] Unblocking all traffic ..."

iptables -t filter -D FORWARD -m physdev --physdev-is-bridged -j DROP
