{ pkgs, ... }:

{

  profiles.base = {
    enable = true;
    stateVersion = "24.05";
    sysConfigName = null;
  };

  homelib = {
    kitty.enable = true;
    git = {
      configOverwritePaths = [ "git/.gitconfig" ];
      ignore.extraRules = [ "**/copilot-instructions.md" ];
    };
    vscode = {
      enable = true;
      flavor = "ms";
      extensions.enable = true;
    };

    k8stools = {
      enable = true;
      minikube.enable = false;
    };

    certtools.enable = true;

  };

  home.packages = with pkgs; [
    keepassxc
    invhosts

    gh
    gh-dash
    gh-stack
  ];

}
