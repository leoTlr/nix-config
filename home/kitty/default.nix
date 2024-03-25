{ pkgs, config, lib, inputs, ... }:
let
  cfg = config.homelib.kitty;
  kittyColorSettings = import ./colors.nix { inherit config; };
in
{ 
 
  options.homelib.kitty = {

    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Use kitty as terminal emulator";
    };
    
    nixcolors.enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable;
      description = "Use github:misterio77/nix-colors for theming";
    };
  
  };

  config.programs.kitty = lib.mkIf cfg.enable {
    enable = true;
    font.name = "JetBrainsMono Nerd Font Mono";
    font.size = 15;

    settings = {
      enable_audio_bell = "no";
      allow_remote_control = "no";
      listen_on = "unix:/tmp/kitty";
      shell_integration = "enabled";
    } // lib.mkIf cfg.nixcolors.enable kittyColorSettings;
  
  };
  
}