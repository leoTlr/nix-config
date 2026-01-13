{ pkgs, userConfig, ... }:

{

  profiles.base = {
    enable = true;
    stateVersion = "25.11";
  };

  homelib = {
    git.commitInfo.signKey = null;

    kitty.enable = true;
    bitwarden = {
      enable = true;
      enableGui = true;
    };

    firefox.enable = true;

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
    lazygit
  ];

}
