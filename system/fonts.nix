{ config, pkgs, lib, ... }:

{
  options.syslib.customFonts.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Configure custom fonts";
  };
  
  config = lib.mkIf config.syslib.customFonts.enable {

    console.font = "Lat2-Terminus16";

    fonts = {
    
      packages = with pkgs; [
        # only dl specific fonts from nerdfonts repo
        (pkgs.nerdfonts.override {fonts = ["JetBrainsMono" "FiraCode"];})
      ];

      enableDefaultPackages = true;

      fontconfig = {
        defaultFonts = {
          monospace = ["JetBrainsMono Nerd Font Mono"];
          sansSerif = ["JetBrainsMono Nerd Font"];
          serif = ["JetBrainsMono Nerd Font"];
        };
      };
    
    };

  }; 
  
}