{ pkgs, config, lib, ... }:
let
  cfg = config.homelib.vscode;
  userSettings = import ./usersettings.nix {};
  extensions = with pkgs.vscode-extensions; [
    eamodio.gitlens
    mhutchie.git-graph
    nvarner.typst-lsp
    mgt19937.typst-preview
    jnoortheen.nix-ide
  ];
in
{
  
  options.homelib.vscode.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Use vscode editor";
  };
  
  config = lib.mkIf cfg.enable {
    
    programs.vscode = {
      enable = true;
      package = pkgs.vscodium;
      inherit extensions userSettings;
    };
    
    home.packages = [ pkgs.nixd ];
  
  };

}