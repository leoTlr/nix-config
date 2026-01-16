{ lib, config, pkgs, ... }:
let
  cfg = config.homelib.hyprland;

  hyprlandSettings = import ./settings.nix {
    inherit config lib pkgs;
  };

  mkColor = base: "rgb(${config.lib.stylix.colors."base0${toString base}"})";

  handleMonitorConnect = pkgs.writeShellApplication {
    name = "handle_monitor_connect";
    text = ''
      hyprland_socket="''${XDG_RUNTIME_DIR}/hypr/''${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock"
      handle_message() {
        case $1 in monitoradded*)
          echo "handling: $1"
          hyprctl dispatch moveworkspacetomonitor "1 0"
          hyprctl dispatch moveworkspacetomonitor "2 1"
        esac
      }
      echo "listening to hyprland socket at $hyprland_socket ..."
      ${lib.getExe pkgs.socat} -u -d --statistics "UNIX-CONNECT:$hyprland_socket" - \
        | while read -r line; do handle_message "$line"; done
    '';
  };

  hyprLogs = pkgs.writeShellApplication {
    name = "hyprlogs";
    runtimeInputs = with pkgs; [ eza fzf less ];
    text = ''
      LOGDIR="$XDG_RUNTIME_DIR/hypr/"
      choice=$(eza -la --modified "$LOGDIR" | cut -d ' ' -f 4,5,6,7 | fzf --height="12%")
      file=$(echo "$choice" | cut -d ' ' -f 4)
      less "$LOGDIR/$file/hyprland.log"
    '';
  };
in
{

  options.homelib.hyprland = with lib; {

    enable = mkEnableOption "custom hyprland desktop environment";

    modkey = mkOption {
      type = types.str;
      default = "SUPER";
      example = "ALT";
    };

    keyMap = mkOption {
      type = types.str;
      example = "de";
    };

    monitors = mkOption {
      type = types.listOf types.str;
      default = [];
      example = ''[
        "eDP-1,1920x1080@60,0x0,1"
        "DP-1,1920x1080@60,1920x0,1"
        "DP-2,1920x1080@60,3840x0,1"
      ]'';
    };

    debugMode = mkEnableOption "hyprland debug mode";

  };

  config = lib.mkIf cfg.enable {

    home.packages = lib.optionals cfg.debugMode [ hyprLogs ];

    systemd.user.services.hyprWorkspacePinner = {
      Unit = {
        Description = "pinning hyprland workspaces to monitors";
        ConditionEnvironment = [ "XDG_RUNTIME_DIR" "HYPRLAND_INSTANCE_SIGNATURE" ];
      };
      Service.ExecStart = lib.getExe handleMonitorConnect;
      Install.WantedBy = [ "hyprland-session.target" ];
    };

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

        listener  =
        let
          timeouts = rec {
            dim = 180; # sec
            lock = dim + 60;
            displayOff = lock + 180;
            suspend = displayOff + 360*2;
          };
        in
        [
          { # dim screen before lock
            timeout    = timeouts.dim;
            on-timeout = "${lib.getExe pkgs.brightnessctl} set 30-";
            on-resume  = "${lib.getExe pkgs.brightnessctl} set 30+";
          }
          { # lock screen
            timeout = timeouts.lock;
            on-timeout = "${lib.getExe pkgs.hyprlock}";
          }
          { # turn screen off
            timeout = timeouts.displayOff;
            on-timeout = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
            on-resume = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";          }
          { # suspend
            timeout = timeouts.suspend;
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
