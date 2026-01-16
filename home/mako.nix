{ config, lib, pkgs, ...}:
let
  cfg = config.homelib.mako;
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

      settings = {

        defaultTimeout = 5000; # ms
        anchor = "bottom-right";
        borderRadius = 10;
        padding = "10";
        icons = true;
        font = "monospace";
        "urgency=low".default-timeout = 2500;

      };
    };
  };
}
