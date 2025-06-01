{ pkgs, userConfig, inputs, ... }:

{

  environment.enableAllTerminfo = true;
  security.sudo.wheelNeedsPassword = false;
  nixpkgs.hostPlatform = "x86_64-linux";
  networking.useDHCP = true;

  users.defaultUserShell = pkgs.fish;

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

  syslib = {

    nix = {
      enable = true;
      remoteManaged = true;
    };

    users = {
      mutable = false;
      mainUser = {
        name = "nixos";
        shell = pkgs.fish;
      };
    };

    sshd = {
      enable = true;
      authorizedKeys.nixos =
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
    killall
    ripgrep
    fd
    ventoy
    inputs.disko.packages."x86_64-linux".default
  ];

  programs.fish.enable = true;

  services.qemuGuest.enable = true;
  virtualisation.incus.agent.enable = true;

}
