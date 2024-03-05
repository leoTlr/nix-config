{ config, pkgs, commonSettings, ... }:
let
  gitConfig = import ./gitconfig.nix {};
  gitAliases = import ./aliases.nix {};
in
{
  home.packages = [ pkgs.git ];

  programs.git = {
    enable = true;
    userName = commonSettings.user.name;

    extraConfig = gitConfig;
    aliases = gitAliases;
  };
}