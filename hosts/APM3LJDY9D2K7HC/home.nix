{ inputs, pkgs, sysConfig, homeConfig, userConfig, ... }:

{

  programs.home-manager.enable = true;

  home = {
    username = userConfig.userName;
    homeDirectory = "/Users/${userConfig.userName}";
    stateVersion = "24.05";

    sessionVariables = {
      EDITOR = "vim";
    };
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
    };
    gpg.enable = false;
    statix.enable = true;
    sops.enable = false;
    just = {
      enable = true;
      nixBuild = {
        enable = true;
        homeConfiguration = homeConfig;
        hostConfiguration = sysConfig;
      };
    };

    firefox.enable = false; # maybe later, for now this is company-managed
    vscode = {
      enable = true;
      flavor = "ms";
    };

  };

  home.packages = with pkgs; [
    #btop
  ];

}
