# Get script directory
SCRIPTDIR=$(dirname $(readlink -f $0))

# Include config
. ${SCRIPTDIR}/config.sh

/usr/sbin/ifconfig $IF_TOAIR 0.0.0.0 up
/usr/sbin/ifconfig $IF_TOGROUND 0.0.0.0 up
/usr/sbin/brctl addbr $IF_BRIDGE
/usr/sbin/brctl addif $IF_BRIDGE $IF_TOAIR
/usr/sbin/brctl addif $IF_BRIDGE $IF_TOGROUND
/usr/sbin/ifconfig $IF_BRIDGE 0.0.0.0 up

# Check if default config file exists
if [ -f /root/emulator/scripts/default.cfg ] ; then
	# Default config exists, use it
	/root/emulator/scripts/emulate.sh /root/emulator/scripts/default.cfg
fi

exit 0
