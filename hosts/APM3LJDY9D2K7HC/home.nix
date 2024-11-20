{ inputs, pkgs, sysConfig, homeConfig, userConfig, ... }:
let
  podprobes = pkgs.writeShellApplication {
    name = "podprobes";
    runtimeInputs = [ pkgs.jq pkgs.openshift ];
    text = ''
      pod=''${1:?'no pod name defined'}
      namespace=''${2:-'default'}
      oc -n "$namespace" get pod "$pod" -o json \
      | jq '.spec.containers.[] | {readinessProbe, livenessProbe, startupProbe}'
    '';
  };
in
{

  programs.home-manager.enable = true;
  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ];
    package = pkgs.nix;
  };

  home = {
    username = userConfig.userName;
    homeDirectory = "/Users/${userConfig.userName}";
    stateVersion = "24.05";

    sessionVariables = {
      EDITOR = "vim";
    };
  };

  colorScheme = inputs.nix-colors.colorSchemes."gruvbox-dark-medium";

  homelib = {
    git = {
      enable = true;
      commitInfo = {
        name = userConfig.git.userName;
        inherit (userConfig) email;
        #inherit (userConfig.git) signKey;
      };
      configOverwritePaths = [ "git/.gitconfig" ];
    };
    gpg.enable = false;
    statix.enable = true;
    sops.enable = false;
    just = {
      enable = true;
      nixBuild = {
        enable = true;
        homeConfiguration = homeConfig;
        hostConfiguration = sysConfig;
      };
    };

    firefox.enable = false; # maybe later, for now this is company-managed
    vscode = {
      enable = true;
      flavor = "ms";
    };

  };

  home.packages = with pkgs; [
    openshift
    podprobes
  ];

}
