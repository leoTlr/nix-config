{ pkgs, config, lib, ... }:
let
  cfg = config.homelib.vscode;
  userSettings = import ./usersettings.nix { inherit pkgs; };
  extensions = with pkgs.vscode-extensions; [
    eamodio.gitlens
    mhutchie.git-graph
    jnoortheen.nix-ide
  ];
in
{

  options.homelib.vscode = with lib; {
    enable = mkEnableOption "vscode editor";
    flavor = mkOption {
      type = types.enum [ "foss" "ms" ];
      default = "foss";
      description = "The build of vscode to use";
    };
  };

  config = lib.mkIf cfg.enable {

    # mac workaround
    nixpkgs.config = lib.mkIf (cfg.flavor == "ms") {
      allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "vscode" ];
    };

    programs.vscode = {
      enable = true;
      package =
        if cfg.flavor == "ms"
        then pkgs.vscode
        else pkgs.vscodium;
      inherit extensions userSettings;
    };

    home.packages = [ pkgs.nixd ];

  };

}