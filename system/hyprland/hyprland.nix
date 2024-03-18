{ pkgs, config, lib, commonSettings, ... }:

{ 
  options.hyprland = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Use hyprland window manager";
    };
  };

  imports = [
    ./pipewire.nix
    ./wayland.nix
    ./dbus.nix
    ../greetd.nix
  ];
  
  config = lib.mkIf config.hyprland.enable {

    environment.systemPackages = with pkgs; [
      polkit
      xdg-desktop-portal-hyprland
      dconf
    ];
  
    programs.hyprland = {
      enable = true;
      xwayland = {
        enable = true;
      };
      portalPackage = pkgs.xdg-desktop-portal-hyprland;
    };

    greetd = {
      enable = true;
      command = if config.isVmGuest then
      ''sh -c "WLR_RENDERER_ALLOW_SOFTWARE=1 ${pkgs.hyprland}/bin/Hyprland"''
      else
      "${pkgs.hyprland}/bin/Hyprland";
    };
    
  };
  

}