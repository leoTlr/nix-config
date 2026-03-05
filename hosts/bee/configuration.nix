{ pkgs, config, ... }:
{

  profiles = {
    base.stateVersion = "24.11";
    server.enable = true;
  };

  boot.initrd = {
    compressor = "zstd";
    compressorArgs = ["-19" "-T0"];
    systemd.enable = true;
  };

  systemd.network.networks."10-lan" = {
    matchConfig.Name = "enp1s0";
    address = [ "192.168.1.50/24" ];
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

  sops.secrets = {
    "alloy/user" = {};
    "alloy/apikey" = {};
    "traefik/certs/bee_cert" = { owner = "traefik"; restartUnits = ["traefik.service"]; };
    "traefik/certs/bee_key" = { owner = "traefik"; restartUnits = ["traefik.service"]; };
    # "authelia/jwtSecret" = { owner = "authelia-main"; };
    # "authelia/storageEncryptionKey" = { owner = "authelia-main"; };
    # "authelia/adminPassword" = { owner = "authelia-main"; };
    "wireguard/bee_priv" = { owner = "systemd-network"; };
    "wireguard/psk" = { owner = "systemd-network"; };
  };

  services.tailscale.enable = true;

  syslib = {

    nfsmounts = {
      enable = true;
      mounts = ["relaxo.home.arpa:/mnt/tank/media:/mnt/relaxo/media"];
    };

    appproxy = {
      enable = true;
      fqdn = "bee.home.arpa";
      auth = {
        enable = false;
        # jwtSecretFile = config.sops.secrets."authelia/jwtSecret".path;
        # storageEncryptionKeyFile = config.sops.secrets."authelia/storageEncryptionKey".path;
        # adminPassword = config.sops.placeholder."authelia/adminPassword";
      };
      certs = [{
        certFile = config.sops.secrets."traefik/certs/bee_cert".path;
        keyFile = config.sops.secrets."traefik/certs/bee_key".path;
      }];
      apps.jellyfin = {
        urlPath = "/";
        routeTo = "http://localhost:8096";

        # jellyfin uses a custom http authorization header scheme that authelia doesnt like.
        # should setup oidc instead
        auth = false;
      };
    };

  };

  services.jellyfin.enable = true;
  systemd.services.jellyfin = {
    wants = [ "mnt-relaxo-media.mount" ];
    after = [ "mnt-relaxo-media.mount" ];
  };

  environment.systemPackages = with pkgs; [
    wireguard-tools
  ];

}
