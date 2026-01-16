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

      packages = with pkgs.nerd-fonts; [
        jetbrains-mono fira-code
      ];

      enableDefaultPackages = true;

      fontconfig = {
        defaultFonts = {
          monospace = ["JetBrainsMono Nerd Font"];
          sansSerif = ["JetBrainsMono Nerd Font"];
          serif = ["JetBrainsMono Nerd Font"];
        };
      };

    };

  };

}
