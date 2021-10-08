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
for i in `seq 1 ${NUM_SLICESTORS}`; do
    qemu-img convert -O qcow2 slicestor.vmdk ${QCOW2_DIR}/cos${SYSTEM}slicestor${i}.qcow2
done
# Cleanup temporary files
rm *.vmdk *.ovf
# Create Slicestor data disk images
for i in `seq 1 ${NUM_SLICESTORS}`; do
    for j in `seq 2 13`; do
	qemu-img create -f qcow2 ${QCOW2_DIR}/cos${SYSTEM}slicestor${i}disk${j}.qcow2 2G
    done
done
# Deploy images to KVM data store directory
sudo mv -f ${QCOW2_DIR}/*.qcow2 /var/lib/libvirt/images/
# Define virtual machines
cd ../src
sudo virt-install --name=COS${SYSTEM}-Manager1 --machine pc --vcpus=2 --ram=4096 --os-variant debian9\
     --network network=${NETWORK},model=virtio --console pty,target_type=serial\
     --disk path=/var/lib/libvirt/images/cos${SYSTEM}manager1.qcow2,bus=ide\
     --graphics vnc,listen=0.0.0.0 --noautoconsole --events on_reboot=restart --boot hd
sudo virt-install --name=COS${SYSTEM}-Accesser1 --machine pc --vcpus=1 --ram=2048 --os-variant debian9\
     --network network=${NETWORK},model=virtio --console pty,target_type=serial\
     --disk path=/var/lib/libvirt/images/cos${SYSTEM}accesser1.qcow2,bus=ide\
     --graphics vnc,listen=0.0.0.0 --noautoconsole --events on_reboot=restart --boot hd
for i in `seq 1 ${NUM_SLICESTORS}`; do
    sudo virt-install --name=COS${SYSTEM}-Slicestor${i} --machine pc --vcpus=1 --ram=3072 --os-variant debian9\
	 --network network=${NETWORK},model=virtio --console pty,target_type=serial\
	 --disk path=/var/lib/libvirt/images/cos${SYSTEM}slicestor${i}.qcow2,bus=ide\
	 --disk path=/var/lib/libvirt/images/cos${SYSTEM}slicestor${i}disk2.qcow2,bus=sata\
	 --disk path=/var/lib/libvirt/images/cos${SYSTEM}slicestor${i}disk3.qcow2,bus=sata\
	 --disk path=/var/lib/libvirt/images/cos${SYSTEM}slicestor${i}disk4.qcow2,bus=sata\
	 --disk path=/var/lib/libvirt/images/cos${SYSTEM}slicestor${i}disk5.qcow2,bus=sata\
	 --disk path=/var/lib/libvirt/images/cos${SYSTEM}slicestor${i}disk6.qcow2,bus=sata\
	 --disk path=/var/lib/libvirt/images/cos${SYSTEM}slicestor${i}disk7.qcow2,bus=sata\
	 --disk path=/var/lib/libvirt/images/cos${SYSTEM}slicestor${i}disk8.qcow2,bus=sata\
	 --disk path=/var/lib/libvirt/images/cos${SYSTEM}slicestor${i}disk9.qcow2,bus=sata\
	 --disk path=/var/lib/libvirt/images/cos${SYSTEM}slicestor${i}disk10.qcow2,bus=sata\
	 --disk path=/var/lib/libvirt/images/cos${SYSTEM}slicestor${i}disk11.qcow2,bus=sata\
	 --disk path=/var/lib/libvirt/images/cos${SYSTEM}slicestor${i}disk12.qcow2,bus=sata\
	 --disk path=/var/lib/libvirt/images/cos${SYSTEM}slicestor${i}disk13.qcow2,bus=sata\
	 --graphics vnc,listen=0.0.0.0 --noautoconsole --events on_reboot=restart --boot hd
done
# Cleanup previous installation
ssh-keygen -R ${BASE_IP}0
ssh-keygen -R ${BASE_IP}1
for i in `seq 1 ${NUM_SLICESTORS}`; do
    IP=$(($i + ${BASE_IP##*.}1))
    ssh-keygen -R ${BASE_IP%.*}.${IP}
done
# Now wait a couple of minutes for the machines to boot up
for i in `seq 1 6`; do
    echo '.'
    sleep 45
done
GW=${BASE_IP%.*}.1
sudo ./cos-manager.expect COS${SYSTEM}-Manager1 ${BASE_IP}0 ${GW}
sudo ./cos-accesser.expect COS${SYSTEM}-Accesser1 ${BASE_IP}1 ${GW} ${BASE_IP}0
for i in `seq 1 ${NUM_SLICESTORS}`; do
  sudo ./cos-slicestor.expect COS${SYSTEM}-Slicestor${i} ${BASE_IP}$(($i + 1)) ${i} ${GW} ${BASE_IP}0
done
