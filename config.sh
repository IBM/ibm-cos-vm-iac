#
# Copyright 2021- hseipp. All rights reserved
# SPDX-License-Identifier: Apache2.0
#
# The KVM network you want to use
NETWORK=default
# When provisioning multiple COS systems at the same time, use this index to identify the system
SYSTEM=1
# IBM Cloud Object Storage version
#VERSION=3.15.5.55
VERSION=3.15.7.83
# Number of SliceStors, tested with 3 and 6 so far
NUM_SLICESTORS=3
# Note that this is the start of a range so 192.168.122.240, 192.168.122.241,... will be used
BASE_IP=192.168.122.240
# Directory for the KVM images
IMG_DIR=/var/lib/libvirt/images
# DNS Servers
DNS_IPS=9.9.9.9,1.1.1.1
# NTP Servers
NTP_IPS=de.pool.ntp.org,us.pool.ntp.org
