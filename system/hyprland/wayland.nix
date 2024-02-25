{ pkgs, commonSettings, ... }:

{
  environment.systemPackages = with pkgs; [ 
    wayland
    xwayland 
  ];

  # Configure xwayland
  services.xserver = {
    enable = true;
    xkb = {
      layout = commonSettings.localization.keymap;
      variant = "";
    };
    
  };

}