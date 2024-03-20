{ pkgs, config, lib, commonSettings, ... }:

{ 
  options.syslib.hyprland = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Use hyprland window manager";
    };
  };
  
  config = lib.mkIf config.syslib.hyprland.enable {

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
      pipewire.enable = true;
      dbus.enable = true;
      wayland = {
        enable = true;
        xwayland.enable = true;
      };
      greetd = {
        enable = true;
        command = if config.profiles.base.system.isVmGuest then
        ''sh -c "WLR_RENDERER_ALLOW_SOFTWARE=1 ${pkgs.hyprland}/bin/Hyprland"''
        else
        "${pkgs.hyprland}/bin/Hyprland";
        userName = config.profiles.base.system.mainUserName;
      };
    };
    
  };
  

}