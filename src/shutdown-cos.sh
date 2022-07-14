#!/bin/sh
#
# Copyright 2021- hseipp. All rights reserved
# SPDX-License-Identifier: Apache2.0
#
source ../config.sh
IP_PREFIX=${BASE_IP%.*}
IP_SUFFIX=${BASE_IP##*.}
for i in `seq 0 $((NUM_SLICESTORS+1))`; do ssh -o "StrictHostKeyChecking no" localadmin@${IP_PREFIX}.$(($IP_SUFFIX + $i)) poweroff; done
