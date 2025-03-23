#!/bin/bash
# Apply or remove emulation

# Get script directory
SCRIPTDIR=$(dirname $(readlink -f $0))

# Include config
. ${SCRIPTDIR}/config.sh

# Binaries
BIN_TC="/usr/sbin/tc"

# Emulation config
declare -A CFG_TOAIR
declare -A CFG_TOGROUND

# Keys for config arrays
KEY_CFG_BANDWIDTHLIMIT_ENABLED="BANDWIDTHLIMIT_ENABLED"
KEY_CFG_BANDWIDTHLIMIT_RATE="BANDWIDTHLIMIT_RATE"
KEY_CFG_DELAY_ENABLED="DELAY_ENABLED"
KEY_CFG_DELAY_TIME="DELAY_TIME"
KEY_CFG_DELAY_DELTA="DELAY_DELTA"
KEY_CFG_DELAY_PERCENTAGE="DELAY_PERCENTAGE"
KEY_CFG_DELAY_DISTRIBUTION="DELAY_DISTRIBUTION"
KEY_CFG_LOSS_ENABLED="LOSS_ENABLED"
KEY_CFG_LOSS_PERCENTAGE="LOSS_PERCENTAGE"
KEY_CFG_LOSS_SUCCESSIVE="LOSS_SUCCESSIVE"
KEY_CFG_DUPLICATE_ENABLED="DUPLICATE_ENABLED"
KEY_CFG_DUPLICATE_PERCENTAGE="DUPLICATE_PERCENTAGE"
KEY_CFG_CORRUPT_ENABLED="CORRUPT_ENABLED"
KEY_CFG_CORRUPT_PERCENTAGE="CORRUPT_PERCENTAGE"
KEY_CFG_REORDER_ENABLED="REORDER_ENABLED"
KEY_CFG_REORDER_PERCENTAGE="REORDER_PERCENTAGE"
KEY_CFG_REORDER_CORRELATION="REORDER_CORRELATION"

# Parse config file
parse_config() {
	ARG_TYPE=$1
	ARG_CFG=$2
	while read LINE
	do
		KEY=`echo $LINE | cut -d '=' -f 1`
		VALUE=`echo $LINE | cut -d '=' -f 2- | sed -e 's/^"//'  -e 's/"$//'`

		if [ $ARG_TYPE -eq 1 ] ; then
			CFG_TOAIR[$KEY]=$VALUE
		else
			CFG_TOGROUND[$KEY]=$VALUE
		fi
	done < $ARG_CFG
}

# Print config
print_config() {
	ARG_TYPE=$1

	if [ $ARG_TYPE -eq 1 ] ; then
		echo "[INFO] Configuration for to-air interface <$IF_TOAIR>"
		for KEY in "${!CFG_TOAIR[@]}"
		do
		        echo "[INFO][CONFIG] $KEY := ${CFG_TOAIR[$KEY]}"
		done
	else
		echo "[INFO] Configuration for to-ground interface <$IF_TOGROUND>"
                for KEY in "${!CFG_TOGROUND[@]}"
                do
                        echo "[INFO][CONFIG] $KEY := ${CFG_TOGROUND[$KEY]}"
                done
	fi
}

# Build command
build_cmd() {
	ARG_TYPE=$1

	BANDWIDTHLIMIT_ENABLED=0
	BANDWIDTHLIMIT_RATE=""
	DELAY_ENABLED=0
	DELAY_TIME=""
	DELAY_DELTA=""
	DELAY_PERCENTAGE=""
	DELAY_DISTRIBUTION=""
	LOSS_ENABLED=0
	LOSS_PERCENTAGE=""
	LOSS_SUCCESSIVE=""
	DUPLICATE_ENABLED=0
	DUPLICATE_PERCENTAGE=""
	CORRUPT_ENABLED=0
	CORRUPT_PERCENTAGE=""
	REORDER_ENABLED=0
	REORDER_PERCENTAGE=""
	REORDER_CORRELATION=""

        if [ $ARG_TYPE -eq 1 ] ; then
		BANDWIDTHLIMIT_ENABLED=${CFG_TOAIR[$KEY_CFG_BANDWIDTHLIMIT_ENABLED]}
		BANDWIDTHLIMIT_RATE=${CFG_TOAIR[$KEY_CFG_BANDWIDTHLIMIT_RATE]}
		DELAY_ENABLED=${CFG_TOAIR[$KEY_CFG_DELAY_ENABLED]}
		DELAY_TIME=${CFG_TOAIR[$KEY_CFG_DELAY_TIME]}
		DELAY_DELTA=${CFG_TOAIR[$KEY_CFG_DELAY_DELTA]}
		DELAY_PERCENTAGE=${CFG_TOAIR[$KEY_CFG_DELAY_PERCENTAGE]}
		DELAY_DISTRIBUTION=${CFG_TOAIR[$KEY_CFG_DELAY_DISTRIBUTION]}
		LOSS_ENABLED=${CFG_TOAIR[$KEY_CFG_LOSS_ENABLED]}
		LOSS_PERCENTAGE=${CFG_TOAIR[$KEY_CFG_LOSS_PERCENTAGE]}
		LOSS_SUCCESSIVE=${CFG_TOAIR[$KEY_CFG_LOSS_SUCCESSIVE]}
		DUPLICATE_ENABLED=${CFG_TOAIR[$KEY_CFG_DUPLICATE_ENABLED]}
		DUPLICATE_PERCENTAGE=${CFG_TOAIR[$KEY_CFG_DUPLICATE_PERCENTAGE]}
		CORRUPT_ENABLED=${CFG_TOAIR[$KEY_CFG_CORRUPT_ENABLED]}
		CORRUPT_PERCENTAGE=${CFG_TOAIR[$KEY_CFG_CORRUPT_PERCENTAGE]}
		REORDER_ENABLED=${CFG_TOAIR[$KEY_CFG_REORDER_ENABLED]}
		REORDER_PERCENTAGE=${CFG_TOAIR[$KEY_CFG_REORDER_PERCENTAGE]}
		REORDER_CORRELATION=${CFG_TOAIR[$KEY_CFG_REORDER_CORRELATION]}
	else
		BANDWIDTHLIMIT_ENABLED=${CFG_TOGROUND[$KEY_CFG_BANDWIDTHLIMIT_ENABLED]}
		BANDWIDTHLIMIT_RATE=${CFG_TOGROUND[$KEY_CFG_BANDWIDTHLIMIT_RATE]}
                DELAY_ENABLED=${CFG_TOGROUND[$KEY_CFG_DELAY_ENABLED]}
                DELAY_TIME=${CFG_TOGROUND[$KEY_CFG_DELAY_TIME]}
                DELAY_DELTA=${CFG_TOGROUND[$KEY_CFG_DELAY_DELTA]}
                DELAY_PERCENTAGE=${CFG_TOGROUND[$KEY_CFG_DELAY_PERCENTAGE]}
                DELAY_DISTRIBUTION=${CFG_TOGROUND[$KEY_CFG_DELAY_DISTRIBUTION]}
                LOSS_ENABLED=${CFG_TOGROUND[$KEY_CFG_LOSS_ENABLED]}
                LOSS_PERCENTAGE=${CFG_TOGROUND[$KEY_CFG_LOSS_PERCENTAGE]}
                LOSS_SUCCESSIVE=${CFG_TOGROUND[$KEY_CFG_LOSS_SUCCESSIVE]}
                DUPLICATE_ENABLED=${CFG_TOGROUND[$KEY_CFG_DUPLICATE_ENABLED]}
                DUPLICATE_PERCENTAGE=${CFG_TOGROUND[$KEY_CFG_DUPLICATE_PERCENTAGE]}
		CORRUPT_ENABLED=${CFG_TOGROUND[$KEY_CFG_CORRUPT_ENABLED]}
                CORRUPT_PERCENTAGE=${CFG_TOGROUND[$KEY_CFG_CORRUPT_PERCENTAGE]}
                REORDER_ENABLED=${CFG_TOGROUND[$KEY_CFG_REORDER_ENABLED]}
                REORDER_PERCENTAGE=${CFG_TOGROUND[$KEY_CFG_REORDER_PERCENTAGE]}
                REORDER_CORRELATION=${CFG_TOGROUND[$KEY_CFG_REORDER_CORRELATION]}
	fi

	CMD="$IF root netem"
	if [ ! -z $BANDWIDTHLIMIT_ENABLED ] && [ $BANDWIDTHLIMIT_ENABLED -eq 1 ] && [ ! -z $BANDWIDTHLIMIT_RATE ] ; then
		CMD="$CMD rate $BANDWIDTHLIMIT_RATE"
	fi
	if [ ! -z $DELAY_ENABLED ] && [ $DELAY_ENABLED -eq 1 ] && [ ! -z $DELAY_TIME ] ; then
		CMD="$CMD delay $DELAY_TIME"
		if [ ! -z $DELAY_DELTA ] ; then
			CMD="$CMD $DELAY_DELTA"
		fi
		if [ ! -z $DELAY_PERCENTAGE ] && [ -z $DELAY_DISTRIBUTION ] ; then
			CMD="$CMD $DELAY_PERCENTAGE"
		fi
		if [ ! -z $DELAY_DISTRIBUTION ] && [ -z $DELAY_PERCENTAGE ] ; then
			CMD="$CMD distribution $DELAY_DISTRIBUTION"
		fi
	fi
	if [ ! -z $LOSS_ENABLED ] && [ $LOSS_ENABLED -eq 1 ] && [ ! -z $LOSS_PERCENTAGE ] ; then
		CMD="$CMD loss $LOSS_PERCENTAGE"
		if [ ! -z $LOSS_SUCCESSIVE ] ; then
			CMD="$CMD $LOSS_SUCCESSIVE"
		fi
	fi
	if [ ! -z $DUPLICATE_ENABLED ] && [ $DUPLICATE_ENABLED -eq 1 ] && [ ! -z $DUPLICATE_PERCENTAGE ] ; then
		CMD="$CMD duplicate $DUPLICATE_PERCENTAGE"
	fi
	if [ ! -z $CORRUPT_ENABLED ] && [ $CORRUPT_ENABLED -eq 1 ] && [ ! -z $CORRUPT_PERCENTAGE ] ; then
		CMD="$CMD corrupt $CORRUPT_PERCENTAGE"
	fi
        if [ ! -z $REORDER_ENABLED ] && [ $REORDER_ENABLED -eq 1 ] && [ ! -z $REORDER_PERCENTAGE ] ; then
                CMD="$CMD reorder $REORDER_PERCENTAGE"
                if [ ! -z $REORDER_CORRELATION ] ; then
                        CMD="$CMD $REORDER_CORRELATION"
                fi
        fi

	echo $CMD
}

# Check binary requirements
if ! command -v $BIN_TC &> /dev/null
then
	echo "[ERROR] tc is not installed, aborting"
	exit 1
fi

# Check interface availability
/usr/sbin/ifconfig $IF_TOAIR &> /dev/null
if [ $? -ne 0 ] ; then
	echo "[ERROR] Incoming interface <$IF_TOAIR> is not available, aborting"
	exit 1
fi

/usr/sbin/ifconfig $IF_TOGROUND &> /dev/null
if [ $? -ne 0 ] ; then
        echo "[ERROR] Incoming interface <$IF_TOGROUND> is not available, aborting"
        exit 1
fi

# Check for reset
if [ "$1" = "reset" ] ; then
	# Clear old qdisc
	QDISC_EXISTS=`$BIN_TC qdisc show dev $IF_TOAIR | grep netem | awk '{print $2}'`
	if [ "$QDISC_EXISTS" = "netem" ] ; then
	        echo "[INFO] Clearing previous configuration from to-air <$IF_TOAIR>"
	        $BIN_TC qdisc del dev $IF_TOAIR root netem
	fi
	QDISC_EXISTS=`$BIN_TC qdisc show dev $IF_TOGROUND | grep netem | awk '{print $2}'`
	if [ "$QDISC_EXISTS" = "netem" ] ; then
	        echo "[INFO] Clearing previous configuration from to-ground <$IF_TOGROUND>"
	        $BIN_TC qdisc del dev $IF_TOGROUND root netem
	fi
	exit 0
fi

# Check for supplied configuration file
IN_CFG_TOAIR=$1
if [ -z $IN_CFG_TOAIR ] ; then
	echo "[ERROR] No config file supplied, aborting"
	exit 1
fi
if [ ! -f $IN_CFG_TOAIR ] ; then
	echo "[ERROR] Supplied config file <$IN_CFG_TOAIR> does not exist, aborting"
	exit 1
fi

# Check if a 2nd config file was given, if we have a second one the first one is for IF_TOAIR and the second one is for IF_TOGROUND
IN_CFG_TOGROUND=$2
if [ -z $IN_CFG_TOGROUND ] ; then
	# Just re-use the first config file
	echo "[INFO] Using given configuration for both directions to-air and to-ground"
	IN_CFG_TOGROUND=$IN_CFG_TOAIR
fi

# Parse config file
parse_config 1 $IN_CFG_TOAIR
parse_config 2 $IN_CFG_TOGROUND

# Print configuration
print_config 1
print_config 2

# Build the final argument string for tc
CMD_TOAIR=$(build_cmd 1)
CMD_TOGROUND=$(build_cmd 2)

echo "[INFO] Command for to-air interface <$CMD_TOAIR>"
echo "[INFO] Command for to-ground interface <$CMD_TOGROUND>"

# Clear old qdisc
QDISC_EXISTS=`$BIN_TC qdisc show dev $IF_TOAIR | grep netem | awk '{print $2}'`
if [ "$QDISC_EXISTS" = "netem" ] ; then
	echo "[INFO] Clearing previous configuration from to-air <$IF_TOAIR>"
	$BIN_TC qdisc del dev $IF_TOAIR root netem
fi
QDISC_EXISTS=`$BIN_TC qdisc show dev $IF_TOGROUND | grep netem | awk '{print $2}'`
if [ "$QDISC_EXISTS" = "netem" ] ; then
	echo "[INFO] Clearing previous configuration from to-ground <$IF_TOGROUND>"
        $BIN_TC qdisc del dev $IF_TOGROUND root netem
fi

# Add new qdisc
echo "[INFO] Adding config for to-air <$IF_TOAIR>"
OUT=`$BIN_TC qdisc add dev $IF_TOAIR $CMD_TOAIR`
if [ $? -ne 0 ] ; then
	echo "[ERROR] Failure adding configuration <$OUT>"
	exit 1
fi
echo "[INFO] Adding config for to-ground <$IF_TOGROUND>"
OUT=`$BIN_TC qdisc add dev $IF_TOGROUND $CMD_TOGROUND`
if [ $? -ne 0 ] ; then
        echo "[ERROR] Failure adding configuration <$OUT>"
        exit 1
fi

exit 0
