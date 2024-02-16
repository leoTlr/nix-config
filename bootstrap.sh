#!/run/current-system/sw/bin/bash

set -eu

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

device="${1:?device not set}"
lukspw="${2:?lukspw not set}"

echo "### Partitioning ${device}"
${SCRIPT_DIR}/partition.sh ${device} ${lukspw}
echo "### Partitioning ${device} successful"

echo "### Installing nixos"
mkdir -p /mnt/etc/nixos/
cp ${SCRIPT_DIR}/hosts/testbox/configuration.nix /mnt/etc/nixos/configuration.nix

nixos-generate-config --root /mnt

nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update

nixos-install
echo "### Successfully installed nixos. Reboot now"
