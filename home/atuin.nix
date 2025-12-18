{ config, lib, ...}:
let
  cfg = config.homelib.atuin;
in
{
  options.homelib.atuin.enable = lib.mkEnableOption "atuin shell history";

  config = lib.mkIf cfg.enable {

    programs.atuin = {
      enable = true;
      settings = {
        style = "compact";
        inline_height = 20;
        history_filter = [ "^\s+" "#nohist" ];
        enter_accept = true;
        filter_mode_shell_up_key_binding = "session";
      };
    };

  };
}
