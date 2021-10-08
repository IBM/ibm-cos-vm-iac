#!/bin/sh
#
# Copyright 2021- hseipp. All rights reserved
# SPDX-License-Identifier: Apache2.0
#
source ../config.sh
sudo virsh destroy COS${SYSTEM}-Manager1
sudo virsh undefine COS${SYSTEM}-Manager1
sudo virsh vol-delete cos${SYSTEM}manager1.qcow2 --pool default
sudo virsh destroy COS${SYSTEM}-Accesser
sudo virsh undefine COS${SYSTEM}-Accesser
sudo virsh vol-delete cos${SYSTEM}accesser1.qcow2 --pool default
for i in `seq 1 ${NUM_SLICESTORS}`
do
    sudo virsh destroy COS${SYSTEM}-Slicestor${i}
    sudo virsh undefine COS${SYSTEM}-Slicestor${i}
    for j in `seq 2 13`
    do
        sudo virsh vol-delete cos${SYSTEM}slicestor${i}disk${j}.qcow2 --pool default
    done
    sudo virsh vol-delete cos${SYSTEM}slicestor${i}.qcow2 --pool default
done
