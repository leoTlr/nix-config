{config, lib, ...}:

{
  options.syslib.greetd = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Use greetd login-manager";
    };
    command = lib.mkOption {
      type = lib.types.str;
      example = ''''${pkgs.hyprland}/bin/start-hyprland'';
    };
    userName = lib.mkOption {
      type = lib.types.str;
    };
  };

  config = lib.mkIf config.syslib.greetd.enable {

    services.greetd = {
      enable = true;

      # https://man.sr.ht/~kennylevinsen/greetd/
      settings = {
        default_session = {
          inherit (config.syslib.greetd) command;
          user = "${config.syslib.greetd.userName}";
        };
      };

    };

  };

}
