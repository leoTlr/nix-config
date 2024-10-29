{ pkgs, config, lib, ... }:
let
  cfg = config.syslib.hyprland;
in
{
  options.syslib.hyprland = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Use hyprland window manager";
    };
    isVmGuest = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether hyprland runs in a VM";
    };
    user = lib.mkOption {
      type = lib.types.str;
      description = "Name of the user under which greetd starts Hyprland";
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      polkit
      xdg-desktop-portal-hyprland
    ];

    programs.hyprland = {
      enable = true;
      xwayland = {
        enable = true;
      };
      portalPackage = pkgs.xdg-desktop-portal-hyprland;
    };

    syslib = {
      localization.enable = true;
      pipewire.enable = true;
      dbus.enable = true;
      wayland = {
        enable = true;
        xwayland = {
          enable = true;
          inherit (config.syslib.localization) keymap;
        };
      };
      greetd = {
        enable = true;
        command = if cfg.isVmGuest then
        ''sh -c "WLR_RENDERER_ALLOW_SOFTWARE=1 ${pkgs.hyprland}/bin/Hyprland"''
        else
        "${pkgs.hyprland}/bin/Hyprland";
        userName = cfg.user;
      };
    };

  };

}