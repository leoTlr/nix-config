{ config, lib, pkgs, ... }:
let
  cfg = config.homelib.kitty;
in
{

  options.homelib.kitty.enable = lib.mkEnableOption "kitty terminal emulator";

  config.programs.kitty = lib.mkIf cfg.enable {
    enable = true;

    # https://sw.kovidgoyal.net/kitty/shell-integration/
    shellIntegration.mode = "no_cursor";

    extraConfig = ''
      enable_audio_bell no
      allow_remote_control no

      # https://sw.kovidgoyal.net/kitty/conf/#window-layout
      # switch layouts: ctrl+shift+l
      enabled_layouts tall,grid,stack
      tab_bar_edge top
      tab_bar_style powerline

      scrollback_lines 10000
    '';

    keybindings = lib.mkIf pkgs.stdenv.isDarwin {
      # toggle window focus
      "super+left" = "next_window";
      "super+right" = "previous_window";
    };

  };

}
