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
            "--grace 2"
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

  config = lib.mkIf cfg.enable {

    # There is waylock which is supposed to be more secure than swaylock
    # but it doesnt work with hyprland: https://codeberg.org/ifreund/waylock/issues/82

    home.packages = [ pkgs.swayidle pkgs.swaylock-effects ];

    services.swayidle = {
      enable = true;
      extraArgs = [];
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
        }
        {
          timeout = cfg.displayOff.waitSec;
          inherit (cfg.displayOff) command resumeCommand;
        }
      ];
      systemdTarget = cfg.systemdBindTarget;
   };

  };
}
