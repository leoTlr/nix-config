{ pkgs, config, lib, ... }:

let
  kittyBaseSettings= {
    enable_audio_bell = "no";
    allow_remote_control = "no";
    listen_on = "unix:/tmp/kitty";
    shell_integration = "enabled";
  };

  kittyColorSettings =
    if ! config.kitty.enableNixColors then {}
    else with config.colorScheme.colors; {
      cursor = "#${base06}";
      cursor_text_color = "background";

      url_color = "#${base0D}";

      visual_bell_color = "#${base0C}";
      bell_border_color = "#${base0C}";

      active_border_color = "#${base0E}";
      inactive_border_color = "#${base03}";

      foreground = "#${base06}";
      background = "#${base00}";
      selection_foreground = "#${base02}";
      selection_background = "#${base06}";

      active_tab_foreground = "#${base06}";
      active_tab_background = "#${base03}";
      inactive_tab_foreground = "#${base04}";
      inactive_tab_background = "#${base01}";

      # = "black  (bg3/bg4)";
      color0 = "#${base03}";
      color8 = "#${base04}";

      # = "red";
      color1 = "#${base08}";
      color9 = "#${base08}";

      #: = "green";
      color2 = "#${base0B}";
      color10 = "#${base0B}";

      # = "yellow";
      color3 = "#${base0A}";
      color11 = "#${base0A}";

      # = "blue";
      color4 = "#${base0D}";
      color12 = "#${base0D}";

      # = "purple";
      color5 = "#${base0E}";
      color13 = "#${base0E}";

      # = "aqua";
      color6 = "#${base0C}";
      color14 = "#${base0C}";

      # = "white (fg4/fg3)";
      color7 = "#${base05}";
      color15 = "#${base06}";
    };
in

{ 
  options.kitty.enableNixColors = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Use github:misterio77/nix-colors for theming";
  };

  config = {
    programs.kitty = {
      enable = true;
      font.name = "JetBrainsMono Nerd Font Mono";
      font.size = 15;

      settings = kittyBaseSettings // kittyColorSettings;
    };
  };
}