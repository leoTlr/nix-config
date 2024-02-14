{ config, pkgs, userSettings, ... }:

{
  imports = [
    ./pipewire.nix
    ./wayland.nix
    ./dbus.nix
  ];

  services.greetd = {
    enable = true;

    # https://man.sr.ht/~kennylevinsen/greetd/
    settings = {
      default_session = {
        # env var can be omitted if not in VM, see https://wiki.hyprland.org/Getting-Started/Quick-start/
        command = ''sh -c "WLR_RENDERER_ALLOW_SOFTWARE=1 ${pkgs.hyprland}/bin/Hyprland"'';
        user = "${userSettings.name}";
      };
    };

  };
  #environment.systemPackages = [ pkgs.greetd.tuigreet ];

  environment.systemPackages = with pkgs; [
    polkit
    xdg-desktop-portal-hyprland
    dconf
    xwayland
  ];
  
  programs.hyprland = {
    enable = true;
    xwayland = {
      enable = true;
    };
    portalPackage = pkgs.xdg-desktop-portal-hyprland;
  };

}