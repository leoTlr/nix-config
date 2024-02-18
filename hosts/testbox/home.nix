{ config, lib, pkgs, localeSettings, userSettings, ... }:

{ 

  imports = [
    ../../user/git.nix
    ../../user/hyprland/hyprland.nix
  ];
  
  home = {
    username = userSettings.name;
    homeDirectory = "/home/${userSettings.name}";
    stateVersion = "23.11";
  };

  wm.modkey = "ALT";
  
  home.packages = with pkgs; [
    lf
    bat
    ripgrep
  ];

  programs.home-manager.enable = true;
  
}
