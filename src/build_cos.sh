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
qemu-img convert -O qcow2 manager.vmdk ${QCOW2_DIR}/cos${SYSTEM}manager1.qcow2
qemu-img convert -O qcow2 accesser.vmdk ${QCOW2_DIR}/cos${SYSTEM}accesser1.qcow2
for I in `seq 1 ${NUM_SLICESTORS}`; do
    qemu-img convert -O qcow2 slicestor.vmdk ${QCOW2_DIR}/cos${SYSTEM}slicestor${I}.qcow2
done
# Cleanup temporary files
rm *.vmdk *.ovf
# Create Slicestor data disk images
for I in `seq 1 ${NUM_SLICESTORS}`; do
    for J in `seq 2 13`; do
	qemu-img create -f qcow2 ${QCOW2_DIR}/cos${SYSTEM}slicestor${I}disk${J}.qcow2 2G
    done
done
# Deploy images to KVM data store directory
sudo mv -f ${QCOW2_DIR}/*.qcow2 ${IMG_DIR}/
# Define virtual machines
cd ../src
sudo virt-install --name=COS${SYSTEM}-Manager1 --machine pc --vcpus=2 --ram=4096 --os-variant debian9\
     --network network=${NETWORK},model=virtio --console pty,target_type=serial\
     --disk path=${IMG_DIR}/cos${SYSTEM}manager1.qcow2,bus=ide\
     --graphics vnc,listen=0.0.0.0 --noautoconsole --events on_reboot=restart --boot hd
sudo virt-install --name=COS${SYSTEM}-Accesser1 --machine pc --vcpus=1 --ram=2048 --os-variant debian9\
     --network network=${NETWORK},model=virtio --console pty,target_type=serial\
     --disk path=${IMG_DIR}/cos${SYSTEM}accesser1.qcow2,bus=ide\
     --graphics vnc,listen=0.0.0.0 --noautoconsole --events on_reboot=restart --boot hd
for I in `seq 1 ${NUM_SLICESTORS}`; do
    sudo virt-install --name=COS${SYSTEM}-Slicestor${I} --machine pc --vcpus=1 --ram=3072 --os-variant debian9\
	 --network network=${NETWORK},model=virtio --console pty,target_type=serial\
	 --disk path=${IMG_DIR}/cos${SYSTEM}slicestor${I}.qcow2,bus=ide\
	 --disk path=${IMG_DIR}/cos${SYSTEM}slicestor${I}disk2.qcow2,bus=sata\
	 --disk path=${IMG_DIR}/cos${SYSTEM}slicestor${I}disk3.qcow2,bus=sata\
	 --disk path=${IMG_DIR}/cos${SYSTEM}slicestor${I}disk4.qcow2,bus=sata\
	 --disk path=${IMG_DIR}/cos${SYSTEM}slicestor${I}disk5.qcow2,bus=sata\
	 --disk path=${IMG_DIR}/cos${SYSTEM}slicestor${I}disk6.qcow2,bus=sata\
	 --disk path=${IMG_DIR}/cos${SYSTEM}slicestor${I}disk7.qcow2,bus=sata\
	 --disk path=${IMG_DIR}/cos${SYSTEM}slicestor${I}disk8.qcow2,bus=sata\
	 --disk path=${IMG_DIR}/cos${SYSTEM}slicestor${I}disk9.qcow2,bus=sata\
	 --disk path=${IMG_DIR}/cos${SYSTEM}slicestor${I}disk10.qcow2,bus=sata\
	 --disk path=${IMG_DIR}/cos${SYSTEM}slicestor${I}disk11.qcow2,bus=sata\
	 --disk path=${IMG_DIR}/cos${SYSTEM}slicestor${I}disk12.qcow2,bus=sata\
	 --disk path=${IMG_DIR}/cos${SYSTEM}slicestor${I}disk13.qcow2,bus=sata\
	 --graphics vnc,listen=0.0.0.0 --noautoconsole --events on_reboot=restart --boot hd
done
# Cleanup previous installation
IP_PREFIX=${BASE_IP%.*}
IP_SUFFIX=${BASE_IP##*.}
for I in `seq 0 $((${NUM_SLICESTORS} + 1))`; do
    ssh-keygen -R ${IP_PREFIX}.$((${IP_SUFFIX} + $I))
done
# Now wait a couple of minutes for the machines to boot up
for I in `seq 1 6`; do
    echo '.'
    sleep 45
done
GW=${IP_PREFIX}.1
sudo ./cos-manager.expect COS${SYSTEM}-Manager1 ${BASE_IP} ${GW} ${DNS_IPS} ${NTP_IPS}
ACCESSER_IP=${IP_PREFIX}.$((${IP_SUFFIX} + 1))
sudo ./cos-accesser.expect COS${SYSTEM}-Accesser1 ${ACCESSER_IP} ${GW} ${DNS_IPS} ${BASE_IP}
for I in `seq 1 ${NUM_SLICESTORS}`; do
  SLICESTOR_IP=${IP_PREFIX}.$((${IP_SUFFIX} + $I + 1))
  sudo ./cos-slicestor.expect COS${SYSTEM}-Slicestor${I} ${SLICESTOR_IP} ${I} ${GW} ${DNS_IPS} ${BASE_IP}
done
