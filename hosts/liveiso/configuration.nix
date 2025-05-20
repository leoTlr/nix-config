{ pkgs, userConfig, inputs, ... }:

{

  environment.enableAllTerminfo = true;
  security.sudo.wheelNeedsPassword = false;
  nixpkgs.hostPlatform = "x86_64-linux";
  networking.useDHCP = true;

  users.defaultUserShell = pkgs.fish;

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

}
