{ config, lib, pkgs, ... }:
let
  cfg = config.homelib.ansibletools;

  ansibleInventoryDir = "~/git/ichp-ocp4/ansible/inventories";
  invhosts = pkgs.writeShellApplication {
    # display hosts from specified ansible inventory interactively
    name = "invhosts";
    runtimeInputs = with pkgs; [ ansible fzf jq ];
    text = ''
      inv_dir=${ansibleInventoryDir}
      inv_choice=$(find "$inv_dir" -name "*.yml" -maxdepth 1 | fzf --height="12%" --layout=reverse)
      groups_json=$(ansible-inventory --export --list -i "$inv_choice" \
        | jq '. | to_entries | map_values(select(.value.hosts != null)) | map_values( {"key": .key, "value": .value.hosts}) | from_entries')
      group_names=$(echo "$groups_json" | jq -r '. | keys[]')
      echo "$group_names" | fzf --height="12%" --layout=reverse | jq -rR --argjson groups "$groups_json" '$groups.[.] | join("\n")'
    '';
  };
in
{
  options.homelib.ansibletools.enable = lib.mkEnableOption "ansibletools";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      ansible
      ansible-lint
      invhosts
    ];
  };
}