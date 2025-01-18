{ inputs, pkgs, config, sysConfig, homeConfig, userConfig, ... }:

{

  programs.home-manager.enable = true;

  home = {
    username = userConfig.userName;
    homeDirectory = "/home/${userConfig.userName}";
    stateVersion = "23.11";

    sessionVariables = {
      EDITOR = "vim";
    };
  };

  colorScheme = inputs.nix-colors.colorSchemes."gruvbox-dark-medium";
  sops.secrets = {
    "${userConfig.userName}/location/latitude" = {};
    "${userConfig.userName}/location/longitude" = {};
  };

  homelib = {
    git = {
      enable = true;
      commitInfo = {
        name = userConfig.git.userName;
        email = userConfig.email;
        inherit (userConfig.git) signKey;
      };
    };
    gpg.enable = true;
    statix.enable = true;
    sops.enable = true;
    just = {
      enable = true;
      homeConfiguration = homeConfig;
      hostConfiguration = sysConfig;
    };

    firefox.enable = true;
    vscode.enable = true;
    zed.enable = true;

    hyprland = {
      enable = true;
      screenLock = true;
      keyMap = userConfig.localization.keymap;
    };

    gammastep = {
      enable = true;
      location = {
        latPath = config.sops.secrets."${userConfig.userName}/location/latitude".path;
        lonPath = config.sops.secrets."${userConfig.userName}/location/longitude".path;
      };
      systemdBindTarget = "hyprland-session.target";
    };
  };

  home.packages = with pkgs; [
    trilium-desktop
    signal-desktop
    bitwarden-cli
  ];

  # there is also services.poweralertd which seems more maintained
  # but it requires upower which I'd need to include in nixosConfiguration
  services.batsignal = {
    enable = true;
    extraArgs = [ "-w 20" "-c 10" "-d 5" "-p" "-e" ];
  };

}
