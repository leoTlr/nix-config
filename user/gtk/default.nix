{ pkgs, config, lib, ... }:
let
  gruvboxPlus = import ./gruvbox-plus.nix { inherit pkgs; };
  cssContent = import ./css.nix { inherit config; };
in 
{

  options.gtk = {

    theming.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable gtk";
    };

    nixcolors.enable = lib.mkOption {
      type = lib.types.bool;
      default = config.gtk.theming.enable;
      description = "Use github:misterio77/nix-colors for theming";
    };

    icons.gruvboxplus.enable = lib.mkOption {
      type = lib.types.bool;
      default = config.gtk.theming.enable;
      description = "Use GruvboxPlus icon theme";
    };

  };

  config = {

    gtk = lib.mkIf config.gtk.theming.enable {
      enable = true;

      theme.package = pkgs.adw-gtk3;
      theme.name = "adw-gtk3";
    } // lib.mkIf config.gtk.icons.gruvboxplus.enable {
      iconTheme.package = gruvboxPlus;
      iconTheme.name = "GruvboxPlus";
    };

    home.file = lib.mkIf config.gtk.icons.gruvboxplus.enable {
      # todo: use xdg
      ".local/share/icons/GruvboxPlus".source = "${gruvboxPlus}";
    };
  
    xdg.configFile = lib.mkIf config.gtk.nixcolors.enable {
      "gtk-4.0/gtk.css" = {
        text = cssContent;
      };
      "gtk-3.0/gtk.css" = {
        text = cssContent;
      };
    };
  
  };
  
}