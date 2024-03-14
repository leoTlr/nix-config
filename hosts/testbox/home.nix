{ config, lib, pkgs, inputs, commonSettings, ... }:
let 
  inherit (inputs) nix-colors;
  homeDir = "/home/${commonSettings.user.name}";
in
{ 

  imports = [
    ../../user
    inputs.nix-colors.homeManagerModules.default
  ];
  
  home = {
    username = commonSettings.user.name;
    homeDirectory = homeDir;
    stateVersion = "23.11";

    sessionVariables = {
      EDITOR = "vim";
    };
  };

  sops.secrets = {
    "ltlr/location/latitude" = {};
    "ltlr/location/longitude" = {};
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
  gpg.enable = true;
  sops.enable = true;
  gammastep = {
    enable = true;
    temperature = { day = 5300; night = 2700; };
    location = {
      latPath = config.sops.secrets."ltlr/location/latitude".path;
      lonPath = config.sops.secrets."ltlr/location/longitude".path;
    };
    systemdBindTarget = "hyprland-session.target";
  };

  programs.home-manager.enable = true;

}
