set -eu

device=${1:?device name must be set}
cryptpassword=${2:?cryptpassword must be set}

echo -e "### Formatting device $device"
sgdisk --clear "${device}" 
sgdisk --new 1::+512MiB --typecode 1:ef00 --change-name 1:boot "${device}" 
sgdisk --new 2::0       --typecode 2:8300 --change-name 2:nixos "${device}"

part_boot="$(ls ${device}* | grep -E "^${device}p?1$")"
part_root="$(ls ${device}* | grep -E "^${device}p?2$")"

echo "boot part: ${part_boot}"
echo "root part: ${part_root}"

echo -e "\n### Creating efi partition"
mkfs.vfat -n "NIXBOOT" -F 32 "${part_boot}"

echo -e "\n### Creating cryptroot"
luks_device_name="cryptroot"
luks_device="/dev/mapper/$luks_device_name"
echo -n ${cryptpassword} | cryptsetup luksFormat --type luks2 --label "$luks_device_name" "${part_root}"
echo -n ${cryptpassword} | cryptsetup luksOpen "${part_root}" "$luks_device_name"
mkfs.ext4 -L nixos $luks_device

sleep 5 # sometimes label does not exist instantly

echo -e "\n### Mounting rootfs to /mnt"
mkdir -p /mnt/
mount /dev/disk/by-label/nixos /mnt

echo -e "\n### Mounting boot to /mnt/boot"
mkdir -p /mnt/boot
mount /dev/disk/by-label/NIXBOOT /mnt/boot
