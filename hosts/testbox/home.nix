{ config, lib, pkgs, inputs, commonSettings, ... }:
let 
  inherit (inputs) nix-colors;
  homeDir = "/home/${commonSettings.user.name}";
in
{ 

  imports = [
    ../../user
    inputs.nix-colors.homeManagerModules.default
    inputs.sops-nix.homeManagerModules.sops
  ];
  
  home = {
    username = commonSettings.user.name;
    homeDirectory = homeDir;
    stateVersion = "23.11";

    sessionVariables = {
      EDITOR = "vim";
    };
  };

  sops = {
    defaultSopsFile = "../../secrets/users/${commonSettings.user.name}.yaml";
    defaultSopsFormat = "yaml";

    gnupg = {
      home = "${homeDir}/.gnupg";
      sshKeyPaths = [];
    };
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

  programs.home-manager.enable = true;

}
