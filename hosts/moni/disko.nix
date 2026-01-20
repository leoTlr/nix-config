let
  btrfsopt = [
    "defaults"
    "compress=zstd"
    "noatime"
    "ssd"
  ];

  # nixos-anywhere flags:
  # --extra-files /tmp/<local dir containing ssh_host_ed25519_key and luks key)
in
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_107496481";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              name = "boot";
              size = "1M";
              type = "ef02";
            };
            esp = {
              name = "esp";
              size = "500M";
              type = "ef00";
              content = {
                type = "filesystem";
                preCreateHook = "sleep 3";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "nixos";
                passwordFile = "/tmp/pass";
                settings.allowDiscards = true;
                content = {
                  type = "btrfs";
                  subvolumes = {
                    "@root" = {
                      mountpoint = "/";
                      mountOptions = btrfsopt;
                    };
                    "@home" = {
                      mountpoint = "/home";
                      mountOptions = btrfsopt;
                    };
                    "@varlog" = {
                      mountpoint = "/var/log";
                      mountOptions = btrfsopt;
                    };
                    "@nix" = {
                      mountpoint = "/nix";
                      mountOptions = btrfsopt;
                    };
                    "@data" = {
                      mountpoint = "/data";
                      mountOptions = btrfsopt;
                    };
                    "@swap" = {
                      mountpoint = "/swap";
                      swap.swapfile.size = "2G";
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
