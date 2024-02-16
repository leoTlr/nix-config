#!/run/current-system/sw/bin/bash

set -eu

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

device="${1:?device not set}"
lukspw="${2:?lukspw not set}"
flake_uri="${3:-github:leoTlr/nix-config#testbox}"

echo "### Partitioning ${device}"
${SCRIPT_DIR}/partition.sh ${device} ${lukspw}
echo "### Partitioning ${device} successful"

echo "### Installing nixos from flake ${flake_uri}"
nix-shell --packages git --run "nixos-install --flake ${flake_uri}"
echo "### Successfully installed nixos. Reboot now"
