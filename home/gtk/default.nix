{ pkgs, config, lib, ... }:
let
  cfg = config.homelib.gtk;
  gruvboxPlus = import ./gruvbox-plus.nix { inherit pkgs; };
  cssContent = import ./css.nix { inherit config; };
in 
{

  options.homelib.gtk = {

    theming.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable gtk";
    };

    nixcolors.enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.theming.enable;
      description = "Use github:misterio77/nix-colors for theming";
    };

    icons.gruvboxplus.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Use GruvboxPlus icon theme";
    };

  };

  config = {

    gtk = lib.mkIf cfg.theming.enable {
      enable = true;

      theme.package = pkgs.adw-gtk3;
      theme.name = "adw-gtk3";

      iconTheme = lib.mkIf cfg.icons.gruvboxplus.enable {
        package = gruvboxPlus;
        name = "GruvboxPlus";
      };
    };

    home.file = lib.mkIf cfg.icons.gruvboxplus.enable {
      # todo: use xdg
      ".local/share/icons/GruvboxPlus".source = "${gruvboxPlus}";
    };
  
    xdg.configFile = lib.mkIf cfg.nixcolors.enable {
      "gtk-4.0/gtk.css" = {
        text = cssContent;
      };
      "gtk-3.0/gtk.css" = {
        text = cssContent;
      };
    };
  
  };
  
}
