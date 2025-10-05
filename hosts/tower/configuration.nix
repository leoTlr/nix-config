{ pkgs, config, userConfig, cfglib, ... }:
let
  hostName = "tower";
in
{

  system.stateVersion = "25.11";

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    inherit hostName;
    networkmanager.enable = true;
    firewall.enable = true;
    nameservers = [ "192.168.1.50" ];
  };

  security.pki.certificates = [
    ''
      homelab ca
      =========
      -----BEGIN CERTIFICATE-----
      MIIBcDCCARagAwIBAgIRAN3CHo6NnQP3WKHPi54y2GkwCgYIKoZIzj0EAwIwFjEU
      MBIGA1UEAxMLTGVvIFJvb3QgQ0EwHhcNMjUwNTMxMjAyNTA3WhcNMzUwNTI5MjAy
      NTA3WjAWMRQwEgYDVQQDEwtMZW8gUm9vdCBDQTBZMBMGByqGSM49AgEGCCqGSM49
      AwEHA0IABDL2Q7xJlPFeBQEWdjPW+MSF5TpROKm6iUr9aZncL87HKOf0cvLVlS8f
      b3xu2fH9Ulydi6Svo4+W5PYLZ984yuOjRTBDMA4GA1UdDwEB/wQEAwIBBjASBgNV
      HRMBAf8ECDAGAQH/AgEBMB0GA1UdDgQWBBQ8dlUBEU+WrEUCAytSSezZwQxw0TAK
      BggqhkjOPQQDAgNIADBFAiAbJ0avET36RAWjQMjKEopx32UjNV/tORzWfF1vZ5h3
      KgIhAKO2RshAHEuQasocZeqmPZJG263Nb6ApUBx5QwobrXlq
      -----END CERTIFICATE-----
    ''
  ];

  environment.enableAllTerminfo = true;
  security.sudo.wheelNeedsPassword = false;

  sops = {
    defaultSopsFile = ./secrets.yaml;
    secrets = {
      "traefik/tls/cert" = { owner = "traefik"; };
      "traefik/tls/certKey" = { owner = "traefik"; };
      "authelia/jwtSecret" = { owner = "authelia-main"; };
      "authelia/storageEncryptionKey" = { owner = "authelia-main"; };
      "authelia/adminPassword" = { owner = "authelia-main"; };
      "alloy/user" = {};
      "alloy/apikey" = {};
      "location/latitude" = { owner = userConfig.userName; sopsFile = cfglib.paths.userSecretsFile userConfig.userName; };
      "location/longitude" = { owner = userConfig.userName; sopsFile = cfglib.paths.userSecretsFile userConfig.userName; };
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

    localization = {
      enable = true;
      inherit (userConfig.localization) timezone locale keymap;
    };
    customFonts.enable = true;

    sshd = {
      enable = true;
      authorizedKeys.${userConfig.userName} =
        [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBTJPFx24iMt77z4a6unaq7EBMy8Hj+28vCZAJCbwdMi" ];
    };

    nh = {
      enable = true;
      flakePath = "/home/leo/nix-config";
    };

    hyprland = {
      enable = true;
      user = userConfig.userName;
    };
    bluetooth.enable = true;

    resourceControl.enable = true;

    alloy = {
      enable = true;
      user = config.sops.placeholder."alloy/user";
      apiKey = config.sops.placeholder."alloy/apikey";
    };

    appproxy = {
      enable = true;
      fqdn = "tower.home.arpa";
      tls = {
        certFile = config.sops.secrets."traefik/tls/cert".path;
        certKeyFile = config.sops.secrets."traefik/tls/certKey".path;
      };
      auth = {
        enable = true;
        jwtSecretFile = config.sops.secrets."authelia/jwtSecret".path;
        storageEncryptionKeyFile = config.sops.secrets."authelia/storageEncryptionKey".path;
        adminPassword = config.sops.placeholder."authelia/adminPassword";
      };
      apps.ai.urlPath = "/";
    };

    aistack.enable = true;
  };

  environment.systemPackages = with pkgs; [
    vim
    git
    python3
    pciutils
    nettools
    gdu
    dysk

    # gpu monitoring
    rocmPackages.rocm-smi
    clinfo
    glances
  ];

  programs.fish.enable = true;

  services.fwupd.enable = true;

}
