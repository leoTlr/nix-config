{ config, lib, pkgs, ... }:
let
  cfg = config.syslib.users;
in
{
  options.syslib.users = {

    mainUser = {
      name = lib.mkOption { type = lib.types.str; };
      shell = lib.mkOption {
        type = lib.types.package;
        description = "The default shell";
        default = pkgs.bash;
      };
      extraGroups = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "wheel" "networkmanager" ];
      };
    };

  };

  config = {
    
    users.users.${cfg.mainUser.name} = {
      isNormalUser = true;
      extraGroups = cfg.mainUser.extraGroups;
      shell = cfg.mainUser.shell;
      initialPassword = "1234"; # to be changed on first login
    };

  };
}