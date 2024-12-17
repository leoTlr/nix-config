{ config, lib, pkgs, ... }:
let
  cfg = config.homelib.k8stools;

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
  podports = pkgs.writeShellApplication {
    name = "podports";
    runtimeInputs = [ pkgs.jq pkgs.openshift ];
    text = ''
      pod=''${1:?'no pod name defined'}
      namespace=''${2:-'default'}
      oc -n "$namespace" get pod "$pod" -o json \
      | jq '.spec.containers.[] | {name, ports}'
    '';
  };
in
{
  options.homelib.k8stools.enable = lib.mkEnableOption "k8stools";

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      kubectl
      openshift
      podprobes
      podports
      kubectx
      k9s
      jq
    ];

    programs.fish.shellAliases = {
      k = "kubectl";
      kx = "kubectx";
      kn = "kubens";
      ocl = "oc login --web";
    };

  };
}
