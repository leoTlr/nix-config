{ inputs, pkgs, homeConfig, userConfig, ... }:

{

  programs.home-manager.enable = true;
  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ];
    package = pkgs.nix;
  };

  home = {
    username = userConfig.userName;
    homeDirectory = "/home/${userConfig.userName}";
    stateVersion = "25.05";
  };

  colorScheme = inputs.nix-colors.colorSchemes."gruvbox-dark-medium";

  homelib = {
    git = {
      enable = true;
      commitInfo = {
        name = userConfig.git.userName;
        inherit (userConfig) email;        #inherit (userConfig.git) signKey;
      };
    };
    statix.enable = true;
    sops.enable = false;
    just = {
      enable = true;
      homeConfiguration = homeConfig;
    };

    firefox.enable = true;
    vscode.enable = true;
    helix.enable = true;
    kitty.enable = true;
  };

  #home.packages = with pkgs; [];

}
