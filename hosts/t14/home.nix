{ pkgs, config, userConfig, ... }:

{

  profiles.base = {
    enable = true;
    stateVersion = "23.11";
  };

  sops.secrets = {
    "location/latitude" = {};
    "location/longitude" = {};
  };

  homelib = {
    kitty.enable = true;
    gpg.enable = true;
    statix.enable = true;
    sops.enable = true;
    bitwarden = {
      enable = true;
      enableGui = true;
    };

    firefox.enable = true;
    vscode.enable = true;
    helix.clipboardPkg = pkgs.wl-clipboard;

    hyprland = {
      enable = true;
      debugMode = false;
      keyMap = userConfig.localization.keymap;
      monitors = [
        "eDP-1,1920x1080@60,0x0,1"
        "DP-1,1920x1080@60,1920x0,1"
        "DP-2,1920x1080@60,3840x0,1"
      ];
    };

    gammastep = {
      enable = true;
      location = {
        latPath = config.sops.secrets."location/latitude".path;
        lonPath = config.sops.secrets."location/longitude".path;
      };
      systemdBindTarget = "hyprland-session.target";
    };

  };

  home.packages = with pkgs; [
    trilium-next-desktop
    signal-desktop
    lazygit
  ];

  # there is also services.poweralertd which seems more maintained
  # but it requires upower which I'd need to include in nixosConfiguration
  services.batsignal = {
    enable = true;
    extraArgs = [ "-w 20" "-c 10" "-d 5" "-p" "-e" ];
  };

}
