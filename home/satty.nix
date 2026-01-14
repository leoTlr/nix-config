{ config, lib, pkgs, ... }:
let
  cfg = config.homelib.satty;
in
{
  options.homelib.satty.enable = lib.mkEnableOption "satty screenshot edit tool";

  config = lib.mkIf cfg.enable {

    programs.satty = {
      enable = true;
      settings.general = {
        early-exit = false; # breaks the actions-on-enter chain
        copy-command = lib.getExe' pkgs.wl-clipboard "wl-copy";
        initial-tool = "rectangle";
        output-filename = "~/screenshot_%Y-%m-%d_%H:%M:%S.png";
        actions-on-enter = [ "save-to-clipboard" "save-to-file" "exit" ];
        actions-on-escape = [ "exit" ];
      };
    };

  };

}
