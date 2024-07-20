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
        name = cfg.gitInfo.name;
        email = cfg.gitInfo.email;
      };
    };
    gpg.enable = true;
    statix.enable = true;
    sops.enable = true;
  };

}