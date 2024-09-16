{ config, lib, pkgs, ...}:
let
  cfg = config.homelib.dunst;
  color = config.colorScheme.palette;
  mkColor = base: "#${color."base0${toString base}"}";
in
{
  options.homelib.dunst.enable = lib.mkEnableOption "dunst";

  config = lib.mkIf cfg.enable {

    home.packages = [
      pkgs.dunst
      pkgs.libnotify
    ];

    services.dunst = {
      enable = true;

      iconTheme = {
        name = "moka-icon-theme";
        package = pkgs.moka-icon-theme;
      };

      settings = {

        global = rec {
          origin = "bottom-right";
          offset = "30x30";
          timeout = 10;
          corner_radius = 10;
          gap_size = 5;
          progress_bar = true;

          background = mkColor "1";
          foreground = mkColor "4";
          frame_color = background;
        };

        urgency_low = {
          timeout = 5;
        };

        urgency_normal = {};

        urgency_critical = {
          timeout = 15;
          foreground = mkColor "8";
        };

      };

    };
  };
}