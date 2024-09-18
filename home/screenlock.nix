{ config, lib, pkgs, ... }:
let
  cfg = config.homelib.screenlock;
  color = config.colorScheme.palette;
in
{
  options.homelib.screenlock = {
    enable = lib.mkEnableOption "screenlock";
    systemdBindTarget = lib.mkOption {
      type = lib.types.str;
      default = "graphical-session-target";
    };
    lock = {
      waitSec = lib.mkOption {
        type = lib.types.ints.positive;
        description = "Seconds until the screenlock activates";
        default = 240;
      };
      command = lib.mkOption {
        type = lib.types.str;
        description = "Command to execute for locking the screen";
        default = lib.strings.concatStringsSep " " [
          "${pkgs.swaylock-effects}/bin/swaylock"
            "--screenshots" "--clock"
            "--indicator" "--indicator-radius 100" "--indicator-thickness 6"
            "--effect-blur 14x10"
            "--effect-vignette 0.5:0.5"
            "--ring-color ${color.base0B}" "--key-hl-color ${color.base08}"
            "--line-color ${color.base00}" "--inside-color ${color.base01}"
            "--separator-color ${color.base00}" "--text-color ${color.base0C}"
            #"--grace 2"
            "--fade-in 0.7"
        ];
      };
    };
    displayDim = {
      waitSec = lib.mkOption {
        type = lib.types.ints.positive;
        description = "Seconds until the screens dim";
        default = cfg.lock.waitSec - 30;
      };
      command = lib.mkOption {
        type = lib.types.str;
        description = "Command to dim the screens";
        default = "${pkgs.brightnessctl}/bin/brightnessctl set 30-";
      };
      resumeCommand = lib.mkOption {
        type = lib.types.str;
        description = "Command to revert dimming the screens";
        default = "${pkgs.brightnessctl}/bin/brightnessctl set 30+";
      };
    };
    displayOff = {
      waitSec = lib.mkOption {
        type = lib.types.ints.positive;
        description = "Seconds until the screens turn off";
        default = cfg.lock.waitSec + 120;
      };
      command = lib.mkOption {
        type = lib.types.str;
        description = "Command to turn off the screens";
        default = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
      };
      resumeCommand = lib.mkOption {
        type = lib.types.str;
        description = "Command to turn off the screens";
        default = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
      };
    };
  };

  config =
    let
      # used until swayidle home-manager module is more configurable
      mkTimeout = t:
        [ "timeout" (toString t.timeout) (lib.escapeShellArg t.command) ]
        ++ lib.optionals (t.resumeCommand != null) [
          "resume"
          (lib.escapeShellArg t.resumeCommand)
        ];
      mkEvent = e: [ e.event (lib.escapeShellArg e.command) ];
      events = [
        {
          event = "lock";
          inherit (cfg.lock) command;
        }
      ];
      timeouts = [
        {
          timeout = cfg.displayDim.waitSec;
          inherit (cfg.displayDim) command resumeCommand;
        }
        {
          timeout = cfg.lock.waitSec;
          inherit (cfg.lock) command;
          resumeCommand = null;
        }
        {
          timeout = cfg.displayOff.waitSec;
          inherit (cfg.displayOff) command resumeCommand;
        }
      ];
      args = (lib.concatMap mkTimeout timeouts) ++ (lib.concatMap mkEvent events);
    in
    lib.mkIf cfg.enable {

    # There is waylock which is supposed to be more secure than swaylock
    # but it doesnt work with hyprland: https://codeberg.org/ifreund/waylock/issues/82

    home.packages = [ pkgs.swayidle pkgs.swaylock-effects ];

    # currently unused in favor of custom systemd unit to prevent a bug
  #   services.swayidle = {
  #     enable = true;
  #     events = [
  #       {
  #         event = "lock";
  #         inherit (cfg.lock) command;
  #       }

  #     ];
  #     timeouts = [
  #       {
  #         timeout = cfg.displayDim.waitSec;
  #         inherit (cfg.displayDim) command resumeCommand;
  #       }
  #       {
  #         timeout = cfg.lock.waitSec;
  #         inherit (cfg.lock) command;
  #       }
  #       {
  #         timeout = cfg.displayOff.waitSec;
  #         inherit (cfg.displayOff) command resumeCommand;
  #       }
  #     ];
  #     systemdTarget = cfg.systemdBindTarget;
  #  };

    # used until home-manager-module makes generated systemd unit customizable (see https://github.com/nix-community/home-manager/pull/5817)
    # Problem is 'swayidle -w' option in systemd unit. It makes me having to unlock twice with certain timeouts.
    # taken from https://github.com/nix-community/home-manager/blob/master/modules/services/swayidle.nix
    systemd.user.services.swayidle = {
      Unit = {
        Description = "Idle manager for Wayland";
        Documentation = "man:swayidle(1)";
        ConditionEnvironment = "WAYLAND_DISPLAY";
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        Type = "simple";
        Restart = "always";
        # swayidle executes commands using "sh -c", so the PATH needs to contain a shell.
        Environment = [ "PATH=${lib.makeBinPath [ pkgs.bash ]}" ];
        ExecStart =
          "${pkgs.swayidle}/bin/swayidle ${lib.concatStringsSep " " args}";
      };

      Install = { WantedBy = [ cfg.systemdBindTarget ]; };
    };

  };
}