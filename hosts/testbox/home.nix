{ config, lib, pkgs, localeSettings, userSettings, nix-colors, ... }:

{ 

  imports = [
    ../../user/git.nix
    ../../user/hyprland/hyprland.nix
    nix-colors.homeManagerModules.default
  ];
  
  home = {
    username = userSettings.name;
    homeDirectory = "/home/${userSettings.name}";
    stateVersion = "23.11";
  };

  wm.modkey = "ALT";
  colorScheme = nix-colors.colorSchemes.gruvbox-dark-medium;
  
  home.packages = with pkgs; [
    lf
    bat
    ripgrep
  ];

  programs.home-manager.enable = true;

}
