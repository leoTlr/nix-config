{ pkgs, config, ... }:
{

  # VM on hetzner
  profiles = {
    base.stateVersion = "25.11";
    server = {
      enable = true;
      monitoring = false;
    };
  };

  boot = {
    loader = {
      systemd-boot.enable = false; # doesnt work on this host
      grub = {
        enable = true;
        efiSupport = true;
        efiInstallAsRemovable = true;
        device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_108060282";
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

  systemd.network.networks."10-lan" = {
    DHCP = "ipv4";
  };

  # wireguard point-to-site homelab access
  # h0=point bee=site
  networking.firewall.allowedUDPPorts = [ 51820 ];
  systemd.network.networks."50-homelab" = {
    matchConfig.Name = "homelab";
    address = [ "10.10.10.2/24" ];
    networkConfig.IPv4Forwarding = true;
    routes = [{
      Gateway = "10.10.10.1";
      GatewayOnLink = true;
      Destination = [ "10.10.10.1/32" "192.168.1.0/24" ];
    }];
  };
  systemd.network.netdevs."50-homelab" = {
    netdevConfig = {
      Kind = "wireguard";
      Name = "homelab";
    };
    wireguardConfig = {
      PrivateKeyFile = config.sops.secrets."wireguard/h0_priv".path;
      ListenPort = 51820;
    };
    wireguardPeers = [{
      PublicKey = "66OY1YutPwnIisQ+/Pm5oApVhaT7YCAIfnZGQT0IQlQ=";
      PresharedKeyFile = config.sops.secrets."wireguard/psk".path;
      AllowedIPs = [ "10.10.10.1/32" "192.168.1.0/24" ];
    }];
  };

  sops.secrets = {
    "wireguard/h0_priv" = { owner = "systemd-network"; };
    "wireguard/psk" = { owner = "systemd-network"; };
  };

  environment.systemPackages = with pkgs; [
    wireguard-tools
  ];

}
