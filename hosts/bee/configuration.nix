{ pkgs, config, userConfig, ... }:
let
  hostName = "bee";
  ip = "192.168.1.50";
in
{

  system.stateVersion = "24.11";
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  boot.initrd = {
    compressor = "zstd";
    compressorArgs = ["-19" "-T0"];
    systemd.enable = true;
  };

  environment.enableAllTerminfo = true;
  security.sudo.wheelNeedsPassword = false;

  networking = {
    inherit hostName;
    firewall.enable = true;
    useNetworkd = true;
  };

  systemd.network.networks."10-lan" = {
    matchConfig.Name = "enp1s0";
    address = [ "${ip}/24" ];
    routes = [{ Gateway = "192.168.1.1"; }];
  };

  # wireguard point-to-site homelab access
  # h0=point bee=site
  networking.firewall.allowedUDPPorts = [ 51820 ];
  systemd.network.networks."50-homelab" = {
    enable = true;
    matchConfig.Name = "homelab";
    address = [ "10.10.10.1/24" ];
    networkConfig = {
      IPv4Forwarding = true;
      IPMasquerade = "ipv4";
    };
  };
  systemd.network.netdevs."50-homelab" = {
    netdevConfig = {
      Kind = "wireguard";
      Name = "homelab";
    };
    wireguardConfig = {
      PrivateKeyFile = config.sops.secrets."wireguard/bee_priv".path;
      ListenPort = 51820;
    };
    wireguardPeers = [{
      PublicKey = "sZu4Mpdisaj7KiYV11IgCuj24xpn59RenpWNt0LCyxc=";
      PresharedKeyFile = config.sops.secrets."wireguard/psk".path;
      AllowedIPs = [ "10.10.10.2/32" ];
      Endpoint = "h0.home.arpa:51820";
      PersistentKeepalive = 20;
    }];
  };

  # dns server
  networking.nameservers = [ "127.0.0.1" ];
  services.resolved.enable = false;
  systemd.services.technitium-dns-server.unitConfig.WantedBy =
    "systemd-networkd.service"; # vpn endpoint cfg contains dns name
  services.technitium-dns-server = {
    enable = true;
    openFirewall = true;
    firewallUDPPorts = [
      53
      853 # DoQUIC
    ];
    firewallTCPPorts = [
      53
      # 443 # DoH
      853 # DoT
      # 5380 # web interface HTTP
      53443 # web interface HTTPS
    ];
  };

  services.tailscale = {
    enable = false;
    openFirewall = true;
  };

  sops = {
    defaultSopsFile = ./secrets.yaml;
    secrets = {
      "traefik/tls/cert" = { owner = "traefik"; };
      "traefik/tls/certKey" = { owner = "traefik"; };
      # "authelia/jwtSecret" = { owner = "authelia-main"; };
      # "authelia/storageEncryptionKey" = { owner = "authelia-main"; };
      # "authelia/adminPassword" = { owner = "authelia-main"; };
      "alloy/user" = {};
      "alloy/apikey" = {};
      "wireguard/bee_priv" = { owner = "systemd-network"; };
      "wireguard/psk" = { owner = "systemd-network"; };
    };
  };

  sops.gnupg = {
    home = "/root/.gnupg";
    sshKeyPaths = [];
  };

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-tty;
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

    bluetooth.enable = false;

    nfsmounts = {
      enable = true;
      mounts = ["relaxo.home.arpa:/mnt/tank/media:/mnt/relaxo/media"];
    };

    appproxy = {
      enable = true;
      fqdn = "bee.home.arpa";
      tls = {
        certFile = config.sops.secrets."traefik/tls/cert".path;
        certKeyFile = config.sops.secrets."traefik/tls/certKey".path;
      };
      auth = {
        enable = false;
        # jwtSecretFile = config.sops.secrets."authelia/jwtSecret".path;
        # storageEncryptionKeyFile = config.sops.secrets."authelia/storageEncryptionKey".path;
        # adminPassword = config.sops.placeholder."authelia/adminPassword";
      };
      apps.jellyfin = {
        urlPath = "/";
        routeTo = "http://localhost:8096";

        # jellyfin uses a custom http authorization header scheme that authelia doesnt like.
        # should setup oidc instead
        auth = false;
      };
    };

    alloy = {
      enable = true;
      user = config.sops.placeholder."alloy/user";
      apiKey = config.sops.placeholder."alloy/apikey";
    };

  };

  services.jellyfin.enable = true;
  systemd.services.jellyfin = {
    wants = [ "mnt-relaxo-media.mount" ];
    after = [ "mnt-relaxo-media.mount" ];
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
    wireguard-tools
  ];

  networking.firewall.allowedTCPPorts = [8096];

  programs.fish.enable = true;

}
