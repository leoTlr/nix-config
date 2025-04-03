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

  minikube_init = pkgs.writeShellApplication {
    name = "minikube_init";
    runtimeInputs = with pkgs; [ minikube kubectl cilium-cli hubble ] ++ lib.optionals (pkgs.stdenv.isDarwin) [ vfkit ];
    text = ''
      # there is the option --cni=cilium for minikube but with this hubble didnt work
      # -> manually install cilium
      echo "minikube_init: installing minikube cluster"
      minikube start --container-runtime=docker --network-plugin=cni --cni=false ${lib.optionalString pkgs.stdenv.isDarwin "--driver=vfkit"}

      echo "minikube_init: installing cilium"
      kubectl config set-context minikube
      cilium install --context minikube
      echo "minikube_init: waiting for cilium to become ready..."
      cilium status --wait

      echo "minikube_init: enabling hubble"
      cilium hubble enable

      echo "minikube_init: finished. Do a 'hubble status -P' to check and destroy cluster again with 'minikube delete'"
    '';
  };
in
{
  options.homelib.k8stools = {
    enable = lib.mkEnableOption "k8stools";
    minikube.enable = lib.mkEnableOption "minikube";
  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      kubectl
      openshift
      podprobes
      podports
      kubectx fzf # optional dependency for kubectx
      k9s
      jq
    ] ++ lib.optionals cfg.minikube.enable [
      minikube
      minikube_init
      cilium-cli
      hubble
    ];

    programs.fish.shellAliases = {
      k = "kubectl";
      kx = "kubectx";
      kn = "kubens";
      ocl = "oc login --web";
    };

  };
}
