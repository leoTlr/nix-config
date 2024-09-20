{ config, lib, userConfig, ... }:
let
  cfg = config.profiles.base;
in
{
  programs.home-manager.enable = true;

  home = {
    username = cfg.home.userName;
    homeDirectory = cfg.home.dir;
    inherit (cfg.home) stateVersion;

    sessionVariables = {
      EDITOR = "vim";
    };
  };

  homelib = {
    git = {
      enable = true;
      commitInfo = {
        name =
          if (builtins.hasAttr "userName" userConfig.git)
          then userConfig.git.userName
          else cfg.home.userName;
        email =
          if (builtins.hasAttr "email" userConfig.git)
          then userConfig.git.email
          else userConfig.email;
        signKey =
          lib.mkIf (builtins.hasAttr "signKey" userConfig.git)
          userConfig.git.signKey;
      };
    };
    gpg.enable = true;
    statix.enable = true;
    sops.enable = true;
    just = {
      enable = true;
      nixBuild = {
        enable = true;
        homeConfiguration = cfg.home.configName;
        hostConfiguration = cfg.system.configName;
      };
    };
  };

}