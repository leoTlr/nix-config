{ pkgs, config, lib, inputs, ... }:
let
  cfg = config.homelib.gtk;
  nix-colors-lib = inputs.nix-colors.lib-contrib { inherit pkgs; };
  gruvboxPlus = import ./gruvbox-plus.nix { inherit pkgs; };
in
{

  options.homelib.gtk = with lib; {
    enable = mkEnableOption "gtk theme";

    icons.gruvboxplus.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Use GruvboxPlus icon theme";
    };

  };

  config = lib.mkIf cfg.enable {

    gtk = {
      enable = true;

      theme = {
        name = config.colorscheme.slug;
        package = nix-colors-lib.gtkThemeFromScheme { scheme = config.colorscheme; };
      };

      iconTheme = lib.mkIf cfg.icons.gruvboxplus.enable {
        package = gruvboxPlus;
        name = "GruvboxPlus";
      };
    };

    home.file = lib.mkIf cfg.icons.gruvboxplus.enable {
      # todo: use xdg
      ".local/share/icons/GruvboxPlus".source = "${gruvboxPlus}";
    };

  };

}
