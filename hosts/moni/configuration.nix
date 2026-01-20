{ pkgs, ... }:
{

  # VM on hetzner
  profiles = {
    base.stateVersion = "26.05";
    server.enable = true;
  };

  boot = {
    loader = {
      systemd-boot.enable = false; # doesnt work on this host
      grub = {
        enable = true;
        efiSupport = true;
        efiInstallAsRemovable = true;
        device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_107496481";
      };
      efi = {
        efiSysMountPoint = "/boot";
        canTouchEfiVariables = false;
      };
    };

    # for remote luks unlock
    kernelParams = [ "ip=dhcp" ];
    initrd = {
      availableKernelModules = [ "virtio-pci" ];
      network = {
        enable = true;
        ssh = {
          enable = true;
          port = 2222;
          authorizedKeys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBTJPFx24iMt77z4a6unaq7EBMy8Hj+28vCZAJCbwdMi"
          ];
          hostKeys = [ "/ssh_host_ed25519_key" ];
          shell = "/bin/cryptsetup-askpass";
        };
      };
    };
  };

  systemd.network.networks."10-wan" = {
    networkConfig = {
      DHCP = "ipv4";
      IPv6AcceptRA = true;
    };
    linkConfig.RequiredForOnline = "routable";
  };

  environment.systemPackages = with pkgs; [
    wireguard-tools
  ];

}
