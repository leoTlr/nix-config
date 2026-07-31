{ pkgs, ... }:

{

  profiles.base = {
    enable = true;
    stateVersion = "24.05";
    sysConfigName = null;
  };

  homelib = {
    kitty.enable = true;
    git.configOverwritePaths = [ "git/.gitconfig" ];

    vscode = {
      enable = true;
      flavor = "ms";
    };

    k8stools = {
      enable = true;
      minikube.enable = false;
    };

    certtools.enable = true;

  };

  home.packages = with pkgs; [
    # keepassxc
    invhosts
  ];

}
