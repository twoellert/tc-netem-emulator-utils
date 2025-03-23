# TC Netam Emulator Scripts
Utility scripts to generate and use the proper _tc_ commands to emulate a link.

Usually this would be installed on a linux machine or VM which has three ethernet links. For example:
* eth0 := For you to SSH into the machine
* eth1 := Link to one side
* eth2 := Link to the other side

The link is then emulated between eth1 and eth2. A transparent bridge is created between eth1 and eth2.
So the machine is not part of the linked network but just applies the link emulation.

## Initial Setup
* Installed and tested on Fedora Server 34
* Execute commands
```
apt update
dnf install bridge-utils iproute-tc kernel-modules-extra
cd /root
```
* Disable SELinux by editing _/etc/selinux/config_ and change the following line:
```
SELINUX=permissive
```
* Disable Fedora firewall
```
systemctl disable firewalld
systemctl stop firewalld
```

## Configuration
To setup which interfaces to use check _config.sh_.

In _default.cfg_ you can see all the tc netem parameters available.

The script setup_network.sh should be run on system startup to create the bridge. It also loads _default.cfg_ and applies the emulation from it to both eth1 and eth2:
```
BANDWIDTHLIMIT_ENABLED="1"
BANDWIDTHLIMIT_RATE="22kbit"
DELAY_ENABLED="1"
DELAY_TIME="350ms"
DELAY_DELTA="90ms"
DELAY_PERCENTAGE="25%"
DELAY_DISTRIBUTION=""
LOSS_ENABLED="0"
LOSS_PERCENTAGE="15.3%"
LOSS_SUCCESSIVE="25%"
DUPLICATE_ENABLED="0"
DUPLICATE_PERCENTAGE="1%"
CORRUPT_ENABLED="0"
CORRUPT_PERCENTAGE="0.1%"
REORDER_ENABLED="0"
REORDER_PERCENTAGE="5%"
REORDER_CORRELATION="50%"
```

If you want to enable a certain setting you need to set XXX_ENABLED to 1 first before the specific settings of this group are applied.

In the example above only BANDWIDTHLIMIT and DELAY is enabled. The others are disabled.

You can have separate configs for eth1 and eth2 to simulate different behaviors in different link directions.

Just create a _upwards.cfg_ and _downwards.cfg_ based on _default.cfg_ and then call the script via:
```
./emulate.sh /root/emulator/scripts/upwards.cfg /root/emulator/scripts/downwards.cfg
```

If you only supply one config file its applied to both directions:
```
./emulate.sh /root/emulator/scripts/both.cfg
```

## Block all traffic
You can run _block.sh_ and _unblock.sh_ manually if you want to block and unblock all traffic on the bridge br0 for testing purposes.