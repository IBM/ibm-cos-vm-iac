#!/bin/sh
#
# Copyright 2021- hseipp. All rights reserved
# SPDX-License-Identifier: Apache2.0
#
source ../config.sh
for i in `seq 0 $((NUM_SLICESTORS+1))`; do ssh -o "StrictHostKeyChecking no" localadmin@${BASE_IP}${i} poweroff; done
