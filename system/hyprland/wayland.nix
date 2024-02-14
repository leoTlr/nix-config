{ pkgs, localeSettings, ... }:

{
  environment.systemPackages = [ pkgs.wayland ];

  # Configure xwayland
  services.xserver = {
    enable = true;
    xkb = {
      layout = localeSettings.keymap;
      variant = "";
    };
    
  };

}