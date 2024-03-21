{ pkgs, config, lib, ... }:
let
  kittyColorSettings = import ./colors.nix { inherit config; };
in
{ 
  options.kitty = {

    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Use kitty as terminal emulator";
    };
    
    nixcolors.enable = lib.mkOption {
      type = lib.types.bool;
      default = config.kitty.enable;
      description = "Use github:misterio77/nix-colors for theming";
    };
  
  };

  config.programs.kitty = lib.mkIf config.kitty.enable {
    enable = true;
    font.name = "JetBrainsMono Nerd Font Mono";
    font.size = 15;

    settings = {
      enable_audio_bell = "no";
      allow_remote_control = "no";
      listen_on = "unix:/tmp/kitty";
      shell_integration = "enabled";
    } // lib.mkIf config.kitty.nixcolors.enable kittyColorSettings;
  
  };
  
}