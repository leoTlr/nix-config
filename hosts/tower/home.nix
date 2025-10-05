{ inputs, pkgs, lib, sysConfig, homeConfig, userConfig, ... }:

{

  programs.home-manager.enable = true;

  home = {
    username = userConfig.userName;
    homeDirectory = "/home/${userConfig.userName}";
    stateVersion = "25.11";
  };

  colorScheme = inputs.nix-colors.colorSchemes."gruvbox-dark-medium";

  homelib = {
    git = {
      enable = true;
      commitInfo = {
        name = userConfig.git.userName;
        inherit (userConfig) email;
      };
    };
    bitwarden = {
      enable = true;
      enableGui = true;
    };
    just = {
      enable = true;
      homeConfiguration = homeConfig;
      hostConfiguration = sysConfig;
    };

    firefox.enable = true;
    helix.enable = true;

    hyprland = {
      enable = true;
      debugMode = false;
      keyMap = userConfig.localization.keymap;
      monitors = [
        "DP-1,3440x1440@164.9,0x0,1"
      ];
    };

    gammastep = {
      enable = true;
      location = {
        latPath = "/run/secrets/location/latitude";
        lonPath = "/run/secrets/location/longitude";
      };
      systemdBindTarget = "hyprland-session.target";
    };
  };

  home.packages = with pkgs; [
    trilium-next-desktop
    signal-desktop
    steam
  ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "steam"
    "steam-unwrapped"
  ];

}
