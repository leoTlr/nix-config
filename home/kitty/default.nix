{ config, lib, pkgs, ... }:
let
  cfg = config.homelib.kitty;
  kittyColorSettings = import ./colors.nix { inherit config; };
in
{

  options.homelib.kitty = {

    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Use kitty as terminal emulator";
    };

    nixcolors.enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable;
      description = "Use github:misterio77/nix-colors for theming";
    };

  };

  config.programs.kitty = lib.mkIf cfg.enable {
    enable = true;

    font.name = "JetBrainsMono Nerd Font Mono";
    font.size = 15;

    # https://sw.kovidgoyal.net/kitty/shell-integration/
    shellIntegration.mode = "no_cursor";

    settings = lib.mkIf cfg.nixcolors.enable kittyColorSettings;

    extraConfig = ''
      enable_audio_bell no
      allow_remote_control no

      # https://sw.kovidgoyal.net/kitty/conf/#window-layout
      # switch layouts: ctrl+shift+l
      enabled_layouts tall,grid,stack
      tab_bar_edge top
      tab_bar_style powerline
    '';

    keybindings = lib.mkIf pkgs.stdenv.isDarwin {
      # toggle window focus
      "super+left" = "next_window";
      "super+right" = "previous_window";
    };

  };

}