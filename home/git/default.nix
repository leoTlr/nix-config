{ config, pkgs, lib, commonSettings, ... }:
let
  cfg = config.homelib.git; 
  gitConfig = import ./gitconfig.nix {};
  gitAliases = import ./aliases.nix {};
  gitIgnore = import ./gitignore.nix {};
in
{ 
  options.homelib.git = {

    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable git";
    };

    aliases.enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable;
      description = "Manage git aliases";
    };

    ignore.enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable;
      description = "Manage git ignores";
    };

  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.git ];

    programs.git = {
      enable = true;
      userName = commonSettings.user.name;

      extraConfig = gitConfig;
      aliases = lib.mkIf cfg.aliases.enable gitAliases;
      ignores = lib.mkIf cfg.ignore.enable gitIgnore;
    };
  };
}