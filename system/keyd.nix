{ config, lib, pkgs, ... }:
let
  cfg = config.syslib.keyd;
in
{
  options.syslib.keyd = with lib; {
    enable = mkEnableOption "keyd key remapper";

  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ pkgs.keyd ];

    services.keyd = {
      enable = true;

      keyboards = {

        umlauts = {

          # ids = [ "0001:0001:3d180807" ];
          ids = [ "*q" ];

          settings = {
            main = {
              "rightalt+a" = "ä";#"unicode(00e4)";  # ä
              # "rightalt+A" = "Ä";#"unicode(00c4)";  # Ä
              "rightalt+o" = "ö";#"unicode(00f6)";  # ö
              # "rightalt+O" = "Ö";#"unicode(00d6)";  # Ö
              "rightalt+u" = "ü";#"unicode(00fc)";  # ü
              # "rightalt+U" = "Ü";#"unicode(00dc)";  # Ü
              "rightalt+s" = "ß";#"unicode(00df)";  # ß
              # "rightalt+e" = "unicode(20ac)";  # €
            };
            shift = {
              "rightalt+a" = "Ä";#"unicode(00e4)";  # ä
              "rightalt+o" = "Ö";#"unicode(00f6)";  # ö
              "rightalt+u" = "Ü";#"unicode(00fc)";  # ü
              "rightalt+s" = "ß";#"unicode(00df)";  # ß
            };
          };
        };
      };

    };

  };
}
