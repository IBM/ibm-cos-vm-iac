#!/bin/bash
#
# Copyright 2021- hseipp. All rights reserved
# SPDX-License-Identifier: Apache2.0
#
source ../config.sh
OVA_DIR=../ova
QCOW2_DIR=../qcow2
cd ${OVA_DIR}
tar xvf clevos-${VERSION}-manager.ova
tar xvf clevos-${VERSION}-accesser.ova
tar xvf clevos-${VERSION}-slicestor.ova
# Convert boot images
qemu-img convert -O qcow2 manager.vmdk ${QCOW2_DIR}/manager.qcow2
qemu-img convert -O qcow2 accesser.vmdk ${QCOW2_DIR}/accesser1.qcow2
for i in `seq 1 ${NUM_SLICESTORS}`; do
    qemu-img convert -O qcow2 slicestor.vmdk ${QCOW2_DIR}/slicestor${i}.qcow2
done
# Cleanup temporary files
rm *.vmdk *.ovf
# Create Slicestor data disk images
for i in `seq 1 ${NUM_SLICESTORS}`; do
    for j in `seq 2 13`; do
	qemu-img create -f qcow2 ${QCOW2_DIR}/slicestor${i}disk${j}.qcow2 2G
    done
done
# Deploy images to KVM data store directory
sudo mv ${QCOW2_DIR}/*.qcow2 /var/lib/libvirt/images/
# Define virtual machines
cd ../src
sudo virsh define COS-Manager.xml
sudo virsh define COS-Accesser.xml
for i in `seq 1 ${NUM_SLICESTORS}`; do
    sudo virsh define COS-Slicestor${i}.xml
done
# Cleanup previous installation
ssh-keygen -R ${BASE_IP}0
ssh-keygen -R ${BASE_IP}1
for i in `seq 1 ${NUM_SLICESTORS}`; do
    IP=$(expr $i + ${BASE_IP##*.}1)
    ssh-keygen -R ${BASE_IP%.*}.${IP}
done
sudo virsh start COS-Manager
sudo virsh start COS-Accesser
for i in `seq 1 ${NUM_SLICESTORS}`; do
    sudo virsh start COS-SliceStor${i}
done
# Now wait a couple of minutes for the machines to boot up
for i in `seq 1 6`; do
    echo '.'
    sleep 30
done
GW=${BASE_IP%.*}.1
sudo ./cos-manager.expect COS-Manager ${BASE_IP}0 ${GW}
sudo ./cos-accesser.expect COS-Accesser ${BASE_IP}1 ${GW} ${BASE_IP}0
sudo ./cos-slicestor.expect COS-SliceStor1 ${BASE_IP}2 1 ${GW} ${BASE_IP}0
sudo ./cos-slicestor.expect COS-SliceStor2 ${BASE_IP}3 2 ${GW} ${BASE_IP}0
sudo ./cos-slicestor.expect COS-SliceStor3 ${BASE_IP}4 3 ${GW} ${BASE_IP}0
