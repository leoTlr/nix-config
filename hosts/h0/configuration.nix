{ pkgs, userConfig, ... }:
let
  # VM on hetzner
  hostName = "h0";
in
{
  system.stateVersion = "25.11";

  boot = {
    loader = {
      # systemd-boot doesnt work
      grub = {
        enable = true;
        efiSupport = true;
        efiInstallAsRemovable = true;
        device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_108060282";
      };
      efi.efiSysMountPoint = "/boot";
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

  environment.enableAllTerminfo = true;

  networking = {
    inherit hostName;
    firewall.enable = true;
    useNetworkd = true;
  };

  systemd.network.networks."10-lan" = {
    enable = true;
    DHCP = "ipv4";
  };

  security.sudo.wheelNeedsPassword = false;

  syslib = {

    nix = {
      enable = true;
      remoteManaged = true;
    };

    users = {
      mutable = true;
      mainUser = {
        name = userConfig.userName;
        shell = pkgs.fish;
      };
    };

    resourceControl.enable = true;

    sshd = {
      enable = true;
      authorizedKeys.${userConfig.userName} =
        [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBTJPFx24iMt77z4a6unaq7EBMy8Hj+28vCZAJCbwdMi" ];
    };

    localization = {
      enable = true;
      inherit (userConfig.localization) timezone locale keymap;
    };

  };

  environment.systemPackages = with pkgs; [
    vim
    git
    dig
    lsof
    dysk
    gdu
    rsync
    helix
    btop
    pciutils
  ];

  programs.fish.enable = true;

}
