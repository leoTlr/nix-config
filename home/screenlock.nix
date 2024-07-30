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
        default = 120;
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
    sleep = {
      waitSec = lib.mkOption {
        type = lib.types.ints.positive;
        description = "Seconds until the pc enters sleep";
        default = 600;
      };
      command = lib.mkOption {
        type = lib.types.str;
        description = "Command to execute for pc to sleep";
        default = "${pkgs.systemd}/bin/systemctl suspend-then-hibernate";
      };
    };
  };

  config = lib.mkIf cfg.enable {

    # There is waylock which is supposed to be more secure than swaylock
    # but it doesnt work with hyprland: https://codeberg.org/ifreund/waylock/issues/82

    home.packages = [ pkgs.swayidle pkgs.swaylock-effects ];

    services.swayidle = {
      enable = true;
      timeouts = [
        {
          timeout = cfg.lock.waitSec;
          inherit (cfg.lock) command;
        }
        {
          timeout = cfg.sleep.waitSec;
          inherit (cfg.sleep) command;
        }
      ];
      systemdTarget = cfg.systemdBindTarget;
   };
  };
}