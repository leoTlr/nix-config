{ pkgs, homeConfig, userConfig, ... }:

{

  profiles.base = {
    enable = true;
    stateVersion = "24.05";
    sysConfigName = null;
  };

  homelib = {
    kitty.enable = true;
    git.configOverwritePaths = [ "git/.gitconfig" ];

    gpg.enable = false;
    statix.enable = true;
    sops.enable = false;

    firefox.enable = false; # maybe later, for now this is company-managed
    vscode = {
      enable = true;
      flavor = "ms";
    };
    k8stools = {
      enable = true;
      minikube.enable = true;
    };
  };

  home.packages = with pkgs; [
    keepassxc
    keepassxc-go # cli
    invhosts
  ];

}
