{ config, lib, pkgs, ... }:
let
  cfg = config.homelib.stylix;
in
{
  options.homelib.stylix = with lib; {
    enable = mkEnableOption "stylix";
    theme = mkOption { type = types.str; };
  };

  config = lib.mkIf cfg.enable {

    stylix = {
      enable = true;

      base16Scheme = "${pkgs.base16-schemes}/share/themes/${cfg.theme}.yaml";

      targets = {
        firefox.enable = false; # using a theme extension for now
        hyprlock.enable = false; # own styling
        waybar.enable = false; # have own css
        helix.enable = false; # built-in gruvbox variant looks much better
      };

      fonts = {

        serif = {
          package = pkgs.nerd-fonts.jetbrains-mono;
          name = "JetbrainsMono Nerd Font";
        };

        sansSerif = {
          package = pkgs.nerd-fonts.jetbrains-mono;
          name = "JetbrainsMono Nerd Font";
        };

        monospace = {
          package = pkgs.nerd-fonts.jetbrains-mono;
          name = "JetbrainsMono Nerd Font";
        };

        emoji = {
          package = pkgs.noto-fonts-color-emoji;
          name = "Noto Color Emoji";
        };

        sizes.terminal = 15;

      };

      cursor = {
        package = pkgs.capitaine-cursors-themed;
        name = "Capitaine Cursors (Gruvbox)";
        size = 32;
      };

      icons = {
        enable = true;
        package = pkgs.gruvbox-plus-icons;
        light = "Gruvbox-Plus-Light";
        dark = "Gruvbox-Plus-Dark";
      };

    };

    # so other apps can access the fonts when stylix nixosModule is not used
    home.packages = config.stylix.fonts.packages;

  };
}
