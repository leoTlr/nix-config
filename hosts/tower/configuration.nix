{ pkgs, userConfig, ... }:
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

  services.tailscale = {
    enable = false;
    openFirewall = true;
    useRoutingFeatures = "both";
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
  };

  environment.systemPackages = with pkgs; [
    vim
    git
    python3
    pciutils
    nettools
  ];

  programs.fish.enable = true;

  services.fwupd.enable = true;

}
