{ config, lib, pkgs, ... }:
let
  cfg = config.syslib.wayland;
in
{ 

  options.syslib.wayland = {
    enable = lib.mkEnableOption "wayland";
    xwayland.enable = lib.mkEnableOption "xwayland";
  };

  config = lib.mkIf cfg.enable {
    
    environment.systemPackages = with pkgs; [ 
      wayland
    ] ++ (if cfg.xwayland.enable then [ xwayland ] else []);

    # Configure xwayland
    services.xserver = lib.mkIf cfg.xwayland.enable {
      enable = true;
      xkb = {
        layout = config.profiles.base.localization.keymap;
        variant = "";
      };
    };

  };

}