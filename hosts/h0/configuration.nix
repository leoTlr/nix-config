{ pkgs, config, userConfig, ... }:
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
  security.sudo.wheelNeedsPassword = false;

  networking = {
    inherit hostName;
    firewall.enable = true;
    useNetworkd = true;
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

  sops.gnupg = {
    home = "/root/.gnupg";
    sshKeyPaths = [];
  };

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-tty;
  };

  sops = {
    defaultSopsFile = ./secrets.yaml;
    secrets = {
      "wireguard/h0_priv" = { owner = "systemd-network"; };
      "wireguard/psk" = { owner = "systemd-network"; };
    };
  };

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
    wireguard-tools
  ];

  programs.fish.enable = true;

}
