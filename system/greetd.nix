{config, lib, userSettings, ...}:

{ 
  options.greetd.command = lib.mkOption {
    type = lib.types.str;
    example = ''''${pkgs.hyprland}/bin/Hyprland'';
  };

  config = {

    services.greetd = {
      enable = true;

      # https://man.sr.ht/~kennylevinsen/greetd/
      settings = {
        default_session = {
          command = config.greetd.command;
          user = "${userSettings.name}";
        };
      };

    };

  };

}