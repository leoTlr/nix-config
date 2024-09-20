{ config, pkgs, lib, userConfig, ... }:
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

    commitInfo = {
      name = lib.mkOption {
        type = lib.types.str;
        default = userConfig.userName;
        description = "User name for commits";
      };
      email = lib.mkOption {
        type = lib.types.str;
        description = "User email for commits";
        default = userConfig.email;
      };
      signKey = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Enable commit signing with given gpg key";
      };
    };

  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.git ];

    programs.git = {
      enable = true;
      userName = cfg.commitInfo.name;
      userEmail = cfg.commitInfo.email;

      extraConfig = gitConfig;
      aliases = lib.mkIf cfg.aliases.enable gitAliases;
      ignores = lib.mkIf cfg.ignore.enable gitIgnore;

      signing = lib.mkIf (cfg.commitInfo.signKey != null) {
        key = cfg.commitInfo.signKey;
        signByDefault = true;
      };
    };
  };
}