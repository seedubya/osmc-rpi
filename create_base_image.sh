#!/bin/bash
#
# create_base_image.sh
#
# OSMC version to download
export OSMC_VERSION=20250302
export OSMC_URL="http://download.osmc.tv/installers/diskimages/OSMC_TGT_rbp4_${OSMC_VERSION}.img.gz"
export DOWNLOAD_DIR=/home/pi/osmc_build
export EXTRACT_DIR=./
export MOUNT_DIR=/home/pi/osmc_build/mnt
export LOOP_DEV=/dev/loop1 # Loop device used for mounting .img file

# create directories
for MYDIR in "${DOWNLOAD_DIR}" "${EXTRACT_DIR}" "${MOUNT_DIR}" ; do
	echo "INFO: Creating '${MYDIR}'..."
	mkdir -p "${MYDIR}" || echo "WARN: Failed '$?'!"
done

echo "INFO: Pulling image from osmc.tv..."
curl -L "$OSMC_URL" -o "${DOWNLOAD_DIR}/OSMC_${OSMC_VERSION}.img.gz"
echo "INFO: Unpacking image..."
gunzip "${DOWNLOAD_DIR}/OSMC_${OSMC_VERSION}.img.gz" # extract image

echo "INFO: Moounting image..."
sudo losetup -P "${LOOP_DEV}" "${DOWNLOAD_DIR}/OSMC_${OSMC_VERSION}.img"
sudo mount "${LOOP_DEV}p1" "${MOUNT_DIR}"

echo "INFO: Copying OSMC filesystem..."
cp -f "${MOUNT_DIR}/filesystem.tar.xz" "${EXTRACT_DIR}"

echo "INFO: Unmounting image..."
sudo umount "${MOUNT_DIR}"
sudo losetup -d "${LOOP_DEV}"

echo "INFO: Removing image..."
rm -f "${DOWNLOAD_DIR}/OSMC_${OSMC_VERSION}.img"

echo "INFO: creating base OSMC image..."
cat "${EXTRACT_DIR}/filesystem.tar.xz" | docker import - "seedubya/osmc-rpi:base_${OSMC_VERSION}"


echo "INFO: Removing filesystem..."
rm -f "${EXTRACT_DIR}/filesystem.tar.xz"
