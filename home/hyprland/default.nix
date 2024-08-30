{ lib, config, pkgs, inputs, ... }:
let
  cfg = config.homelib.hyprland;
  hyprlandSettings = import ./settings.nix {
    inherit config lib pkgs;
  };

  mkColor = base: "rgb(${config.colorscheme.palette."base0${toString base}"})";
in
{

  imports = [
    ../gtk
    ../waybar
    ../kitty
    inputs.hyprcursor-phinger.homeManagerModules.hyprcursor-phinger
  ];

  options.homelib.hyprland = {

    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Use hyprland wm";
    };

    modkey = lib.mkOption {
      type = lib.types.str;
      default = "SUPER";
      example = "ALT";
    };

    keyMap = lib.mkOption {
      type = lib.types.str;
      example = "de";
    };

  };

  config = lib.mkIf cfg.enable {

    homelib = {
      kitty.enable = true;
      gtk.theming.enable = true;
      waybar.enable = true;
      dunst.enable = true;
    };

    # volume/brightness notification
    # alternative: https://github.com/heyjuvi/avizo
    services.swayosd = {
      enable = true;
      topMargin = 0.9;
    };

    programs.hyprcursor-phinger.enable = true;

    wayland.windowManager.hyprland = {
      enable = true;
      package = pkgs.hyprland;
      xwayland.enable = true;
      systemd.enable = true; # hyprland-session.target

      settings = hyprlandSettings;
    };

    services.hypridle = {
      enable = true;

      settings = {

        listener  = [
          { # dim screen before lock
            timeout    = 180;
            on-timeout = "${pkgs.brightnessctl}/bin/brightnessctl set 30-";
            on-resume  = "${pkgs.brightnessctl}/bin/brightnessctl set 30+";
          }
          { # lock screen
            timeout = 240;
            #on-timeout = "loginctl lock-session";
            on-timeout = "${lib.getExe pkgs.hyprlock}";
          }
          { # suspend
            timeout = 240 + 360;
            on-timeout = "systemctl suspend-then-hibernate";
          }
        ];

      };
    };

    programs.hyprlock = {
      enable = true;

      settings = {

        general = {
          grace = 2;
        };

        background = [{
          path = "screenshot";
          blur_passes = 3;
          blur_size = 8;
        }];

        label = [
          { # date
            monitor = "";
            text = ''cmd[update:1000] echo -e "$(date +"%A %d. %b")"'';
            color = mkColor 6;
            font_size = 48;
            font_family = "JetBrains Mono Nerd Font Mono ExtraBold";
            position = "0, 0";
            halign = "center";
            valign = "center";
          }
          { # time
            monitor = "";
            text = ''cmd[update:1000] echo -e "$(date +"%X")"'';
            color = mkColor 6;
            font_size = 32;
            font_family = "JetBrains Mono Nerd Font Mono ExtraBold";
            position = "0, -70";
            halign = "center";
            valign = "center";
          }
        ];

        input-field = [{
          size = "200, 50";
          position = "0, -460";
          monitor = "";
          dots_center = true;
          fade_on_empty = false;
          font_color = mkColor 6;
          inner_color = mkColor 2;
          outer_color = mkColor 0;
          outline_thickness = 2;
          #placeholder_text = '\'<span foreground="##cad3f5">Password...</span>'\';
          shadow_passes = 2;
        }];

      };

    };
  };
}
