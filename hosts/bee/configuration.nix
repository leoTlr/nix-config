{ pkgs, userConfig, ... }:
let
  hostName = "bee";
in
{

  system.stateVersion = "24.11";
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  environment.enableAllTerminfo = true;

  networking = {
    inherit hostName;
    firewall.enable = true;
    useNetworkd = true;
  };

  systemd.network.networks."10-lan" = {
    enable = true;
    matchConfig.Name = "enp1s0";
    address = [
      "192.168.1.50/24"
    ];
    routes = [
      { Gateway = "192.168.1.1"; }
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  services.adguardhome = {
    enable = true;
    mutableSettings = false;
    openFirewall = true;
    allowDHCP = false;
    port = 3000;
    host = "0.0.0.0";
    settings = {
      dhcp.enabled = false;
      http.address = "192.168.1.50:3000";
      dns = {
        bind_hosts = [ "0.0.0.0" ];
        port = 53;
        ratelimit = 300;
        upstream_dns = [
          # DoH
          "https://dns.quad9.net:443/dns-query"
          "https://dns.cloudflare.com:443/dns-query"
        ];
        bootstrap_dns = [
          "9.9.9.9"
          "1.1.1.1"
        ];
      };
      filters = [
        {
          name = "AdGuard DNS filter";
          url = "https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt";
          enabled = true;
        }
        {
          name = "AdAway Default Blocklist";
          url = "https://adaway.org/hosts.txt";
          enabled = true;
        }
        {
          name = "OISD (Big)";
          url = "https://big.oisd.nl";
          enabled = true;
        }
      ];
      filtering.rewrites = [
        # .home.arpa. shall be used for home networks as described in RFC8375
        # https://datatracker.ietf.org/doc/html/rfc8375
        { domain = "t14.home.arpa"; answer = "192.168.1.104"; } # FIXME: use static nw for t14, currently dhcp
        { domain = "bee.home.arpa"; answer = "192.168.1.50"; }
      ];
    };
  };
  networking.firewall.allowedUDPPorts = [ 53 ];
  networking.nameservers = [ "127.0.0.1" ];
  services.resolved.enable = false;

  services.tailscale = {
    enable = false;
    openFirewall = true;
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
  };

  environment.systemPackages = with pkgs; [
    vim
    git
    dig
    lsof
  ];

  programs.fish.enable = true;

}
