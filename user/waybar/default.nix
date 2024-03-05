{ pkgs, config, ... }:
let
  waybarConfig = import ./config.nix { inherit pkgs; };
  waybarCss = import ./styling.nix {};
in 
{
  
  programs.waybar = {
    enable = true;
    settings.mainBar = waybarConfig;
    style = waybarCss;
  };
  
}