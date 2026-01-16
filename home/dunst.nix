{ config, lib, pkgs, ...}:
let
  cfg = config.homelib.dunst;
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

      settings = {

        global = {
          origin = "bottom-right";
          offset = "30x30";
          timeout = 10;
          corner_radius = 10;
          gap_size = 5;
          progress_bar = true;
        };

        urgency_low.timeout = 5;
        urgency_critical.timeout = 15;

      };

    };
  };
}
