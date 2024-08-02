{ config, ... }:
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
        inherit (cfg.gitInfo) name;
        inherit (cfg.gitInfo) email;
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