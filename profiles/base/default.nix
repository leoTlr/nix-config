{ config, lib, pkgs, hostConfig, userConfig, ... }:
let
  cfg = config.profiles.base;
in
{
  options.profiles.base = with lib; {
    enable = mkEnableOption "server base profile";
    stateVersion = mkOption { type = types.str; };
    hostName = mkOption { type = types.str; default = hostConfig; };
  };

  config = lib.mkIf cfg.enable {

    system.stateVersion = cfg.stateVersion;

    boot.loader = {
      systemd-boot.enable = lib.mkDefault true;
      efi.canTouchEfiVariables = lib.mkDefault true;
    };

    networking = {
      hostName = lib.mkDefault hostConfig;
      firewall.enable = lib.mkDefault true;
    };

    programs.fish.enable = lib.mkDefault true;
    environment.enableAllTerminfo = lib.mkDefault true; # i.e. for kitty

    security.pki.certificates = lib.mkDefault [
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

    syslib = {

      nix.enable = lib.mkDefault true;

      users = {
        mutable = lib.mkDefault true;
        mainUser = {
          name = userConfig.userName;
          shell = lib.mkDefault pkgs.fish;
        };
      };

      localization = {
        enable = true;
        timezone = lib.mkDefault userConfig.localization.timezone;
        locale = lib.mkDefault userConfig.localization.locale;
        keymap = lib.mkDefault userConfig.localization.keymap;
      };

    };

    environment = {
      shellAliases = {
        la = "ls -lah";
        lh = "ls -lh";
        sctl = "systemctl";
        sctls = "systemctl status";
        jctl = "journalctl";
        jctlu = "journalctl -eu";
        jctlf = "journalctl -fu";
      };
      systemPackages = with pkgs; [
        vim
        git
        dig
        lsof
        killall
        ripgrep
        fd
        jq
        gdu
        dysk
        rsync
        helix
        btop
        tealdeer
        pciutils
        nettools
      ];
    };

  };
}
