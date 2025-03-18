{ inputs, pkgs, homeConfig, userConfig, ... }:
let
  invhosts = pkgs.writeShellApplication {
    name = "invhosts";
    runtimeInputs = with pkgs; [ coreutils ansible fzf ];
    text = ''
    inv_dir=~/git/ichp-ocp4/ansible/inventories
    inv_choice=$(find "$inv_dir" -name "*.yml" -maxdepth 1 | fzf --height="12%" --layout=reverse)
    groups_json=$(ansible-inventory --export --list -i "$inv_choice" \
      | jq '. | to_entries | map_values(select(.value.hosts != null)) | map_values( {"key": .key, "value": .value.hosts}) | from_entries')
    group_names=$(echo "$groups_json" | jq -r '. | keys[]')
    echo "$group_names" | fzf --height="12%" --layout=reverse | jq -rR --argjson groups "$groups_json" '$groups.[.] | join("\n")'
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
      homeConfiguration = homeConfig;
    };

    firefox.enable = false; # maybe later, for now this is company-managed
    vscode = {
      enable = true;
      flavor = "ms";
    };
    helix.enable = true;
    k8stools.enable = true;
  };

  home.packages = with pkgs; [
    ansible
    ansible-lint
    keepassxc
    keepassxc-go # cli
    invhosts
  ];

}
