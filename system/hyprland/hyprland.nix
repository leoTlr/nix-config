{ pkgs, config, commonSettings, ... }:

{
  imports = [
    ./pipewire.nix
    ./wayland.nix
    ./dbus.nix
    ../greetd.nix
    ./fonts.nix
  ];

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

}