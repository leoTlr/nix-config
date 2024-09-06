{ config, lib, pkgs, ...}:
let
  cfg = config.homelib.mako;
  color = config.colorScheme.palette;
in
{
  options.homelib.mako.enable = lib.mkEnableOption "mako";

  config = lib.mkIf cfg.enable {

    home.packages = [
      pkgs.mako
      pkgs.libnotify
    ];

    services.mako = {
      enable = true;
      defaultTimeout = 5000; # ms
      anchor = "bottom-right";
      backgroundColor = "#${color.base01}";
      textColor = "#${color.base06}";
      borderColor = "#${color.base02}";
      #progressColor = "over #414559";
      borderRadius = 10;
      padding = "10";
      extraConfig = ''
        text-alignment=center
        [urgency=low]
        default-timeout=2500
        [urgency=high]
        text-color=#${color.base07}
        border-color=#${color.base08}
      '';
    };
  };
}