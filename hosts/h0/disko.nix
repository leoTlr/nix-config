let
  btrfsopt = [
    "defaults"
    "compress=zstd"
    "noatime"
    "ssd"
  ];
in
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_108060282";
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
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "nixos";
                # passwordFile = "/tmp/pass";
                # additionalKeyFiles = ["/nixos-enc.key"];
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
