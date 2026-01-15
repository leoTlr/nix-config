{ pkgs, config, lib, inputs, ... }:
let
  cfg = config.homelib.gtk;
  nix-colors-lib = inputs.nix-colors.lib-contrib { inherit pkgs; };
in
{

  options.homelib.gtk = with lib; {
    enable = mkEnableOption "gtk theme";
    iconThemePkg = lib.mkOption {
      type = types.nullOr types.package;
      default = pkgs.gruvbox-plus-icons;
    };
  };

  config = lib.mkIf cfg.enable {

    gtk = {
      enable = true;

      theme = {
        name = config.colorscheme.slug;
        package = nix-colors-lib.gtkThemeFromScheme { scheme = config.colorscheme; };
      };

      iconTheme = lib.mkIf (cfg.iconThemePkg != null) {
        package = cfg.iconThemePkg;
        name = cfg.iconThemePkg.pname;
      };

    };

  };

}
