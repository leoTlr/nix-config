{ config, lib, pkgs, ... }:
let
  cfg = config.syslib.wayland;
in
{

  options.syslib.wayland = with lib; {
    enable = mkEnableOption "wayland";
    xwayland = {
      enable = mkEnableOption "xwayland";
      keymap = mkOption { type=types.str; };
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      wayland
    ] ++ (if cfg.xwayland.enable then [ xwayland ] else []);

    # Configure xwayland
    services.xserver = lib.mkIf cfg.xwayland.enable {
      enable = true;
      xkb = {
        layout = cfg.xwayland.keymap;
        variant = "";
      };
    };

  };

}