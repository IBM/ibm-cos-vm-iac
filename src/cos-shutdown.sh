#!/bin/sh
#
# Copyright 2021- hseipp. All rights reserved
# SPDX-License-Identifier: Apache2.0
#
source ../config.sh
for i in `seq 0 4`; do ssh localadmin@${BASE_IP}${i} poweroff; done
