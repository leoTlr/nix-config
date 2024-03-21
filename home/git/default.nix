{ config, pkgs, lib, commonSettings, ... }:
let
  gitConfig = import ./gitconfig.nix {};
  gitAliases = import ./aliases.nix {};
  gitIgnore = import ./gitignore.nix {};
in
{ 
  options.git = {

    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable git";
    };

    aliases.enable = lib.mkOption {
      type = lib.types.bool;
      default = config.git.enable;
      description = "Manage git aliases";
    };

    ignore.enable = lib.mkOption {
      type = lib.types.bool;
      default = config.git.enable;
      description = "Manage git ignores";
    };

  };

  config = lib.mkIf config.git.enable {
    home.packages = [ pkgs.git ];

    programs.git = {
      enable = true;
      userName = commonSettings.user.name;

      extraConfig = gitConfig;
      aliases = lib.mkIf config.git.aliases.enable gitAliases;
      ignores = lib.mkIf config.git.ignore.enable gitIgnore;
    };
  };
}