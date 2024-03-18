{config, lib, commonSettings, ...}:

{ 
  options.greetd = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Use greetd login-manager";
    };
    command = lib.mkOption {
      type = lib.types.str;
      example = ''''${pkgs.hyprland}/bin/Hyprland'';
    };
  };

  config = lib.mkIf config.greetd.enable {

    services.greetd = {
      enable = true;

      # https://man.sr.ht/~kennylevinsen/greetd/
      settings = {
        default_session = {
          inherit (config.greetd) command;
          user = "${commonSettings.user.name}";
        };
      };

    };

  };

}