{ config, lib, inputs, ... }:
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
  };

  config = {
    profiles.base.enable = true;

    sops.secrets = {
      "${basecfg.home.userName}/location/latitude" = {};
      "${basecfg.home.userName}/location/longitude" = {};
    };

    colorScheme = inputs.nix-colors.colorSchemes.gruvbox-dark-medium;

    homelib = {
      firefox.enable = true;
      vscode.enable = true;

      hyprland = {
        enable = true;
        modkey = if config.profiles.base.system.isVmGuest then "ALT" else "SUPER";
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

  };

}