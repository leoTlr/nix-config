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

  wm.modkey = "ALT";
  colorScheme = inputs.nix-colors.colorSchemes.gruvbox-dark-medium;

  programs.home-manager.enable = true;

}
