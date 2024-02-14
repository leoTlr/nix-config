{config, pkgs, ... }: 
{ 
  home.packages = with pkgs; [
    kitty
  ];
  
  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    xwayland.enable = true;
    systemd.enable = false; # hyprland-session.target
  };
}
