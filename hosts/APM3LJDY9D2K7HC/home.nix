{ inputs, pkgs, homeConfig, userConfig, ... }:

{

  programs.home-manager.enable = true;
  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ];
    package = pkgs.nix;
  };

  home = {
    username = userConfig.userName;
    homeDirectory = "/Users/${userConfig.userName}";
    stateVersion = "24.05";
  };

  colorScheme = inputs.nix-colors.colorSchemes."gruvbox-dark-medium";

  homelib = {
    git = {
      enable = true;
      commitInfo = {
        name = userConfig.git.userName;
        inherit (userConfig) email;
        #inherit (userConfig.git) signKey;
      };
      configOverwritePaths = [ "git/.gitconfig" ];
    };
    gpg.enable = false;
    statix.enable = true;
    sops.enable = false;
    just = {
      enable = true;
      homeConfiguration = homeConfig;
    };

    firefox.enable = false; # maybe later, for now this is company-managed
    vscode = {
      enable = true;
      flavor = "ms";
    };
    helix.enable = true;
    k8stools = {
      enable = true;
      minikube.enable = true;
    };
    ansibletools.enable = true;
    kitty.enable = true;
  };

  home.packages = with pkgs; [
    keepassxc
    keepassxc-go # cli
  ];

}
