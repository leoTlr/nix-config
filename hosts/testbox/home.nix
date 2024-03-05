{ config, lib, pkgs, inputs, commonSettings, ... }:
let 
  inherit (inputs) nix-colors;
in
{ 

  imports = [
    ../../user
    inputs.nix-colors.homeManagerModules.default
  ];
  
  home = {
    username = commonSettings.user.name;
    homeDirectory = "/home/${commonSettings.user.name}";
    stateVersion = "23.11";
  };

  hyprland = {
    enable = true;
    modkey = "ALT";
  };
  colorScheme = inputs.nix-colors.colorSchemes.gruvbox-dark-medium;
  firefox.enable = true;
  statix.enable = true;
  vscode.enable = true;
  git.enable = true;

  programs.home-manager.enable = true;

}
