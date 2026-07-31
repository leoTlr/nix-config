{ pkgs, lib, config, ... }:
let
  cfg = config.homelib.certtools;

  certinfo = pkgs.writeShellApplication {
    name = "certinfo";
    runtimeInputs = [ pkgs.openssl ];
    text = ''
      input="''${1:-/dev/stdin}"

      if [[ $# -gt 1 || "$input" == /dev/stdin && -t 0 ]]; then
        echo "Usage: certinfo [certificate.crt|-]" >&2
        exit 1
      fi

      openssl x509 -in "$input" -noout -text \
        -certopt no_sigdump,no_pubkey,no_header
    '';
  };

  reqinfo = pkgs.writeShellApplication {
    name = "reqinfo";
    runtimeInputs = [ pkgs.openssl ];

    text = ''
      input="''${1:-/dev/stdin}"

      if [[ $# -gt 1 || "$input" == /dev/stdin && -t 0 ]]; then
        echo "Usage: reqinfo [request.csr|-]" >&2
        exit 1
      fi

      openssl req -in "$input" -noout -text \
        -reqopt no_sigdump,no_pubkey,no_header
    '';
  };

in
{
  options.homelib.certtools.enable = lib.mkEnableOption "tools to help handling x509 certificates";

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      openssl
      step-cli
      certinfo
      reqinfo
    ];

  };
}
