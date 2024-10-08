{ config, lib, inputs, pkgs, ... }:
let
  cfg = config.profiles.desktop;
  basecfg = config.profiles.base;
in
{
  imports = [
    ../../../profiles/base/home
    inputs.nix-colors.homeManagerModules.default
  ];

  options.profiles.desktop = {

    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Treat host as desktop";
    };

    colorScheme = lib.mkOption {
      # one of https://github.com/tinted-theming/schemes/tree/spec-0.11/base16
      type = lib.types.str;
      default = "gruvbox-dark-medium";
    };

  };

  config = {
    profiles.base.enable = true;

    sops.secrets = {
      "${basecfg.home.userName}/location/latitude" = {};
      "${basecfg.home.userName}/location/longitude" = {};
    };

    colorScheme = inputs.nix-colors.colorSchemes.${cfg.colorScheme};

    homelib = {
      firefox.enable = true;
      vscode.enable = true;

      hyprland = {
        enable = true;
        modkey = if config.profiles.base.system.isVmGuest then "ALT" else "SUPER";
        screenLock = true;
        keyMap = basecfg.localization.keymap;
      };

      gammastep = {
        enable = true;
        location = {
          latPath = config.sops.secrets."${basecfg.home.userName}/location/latitude".path;
          lonPath = config.sops.secrets."${basecfg.home.userName}/location/longitude".path;
        };
        systemdBindTarget = "hyprland-session.target";
      };
    };

    home.packages = with pkgs; [
      trilium-desktop
      btop
    ];

    # there is also services.poweralertd which seems more maintained
    # but it requires upower which I'd need to include in system profile
    services.batsignal = {
      enable = true;
      extraArgs = [ "-w 20" "-c 10" "-d 5" "-p" ];
    };

  };

}