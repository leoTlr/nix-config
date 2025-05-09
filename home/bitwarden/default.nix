{ config, lib, pkgs, ...}:
let
  cfg = config.homelib.bitwarden;

  createScript = pkgs.python3Packages.buildPythonApplication rec {
    pname = "bw_create";
    version = "0.1.0";
    dontUnpack = true;
    pyproject = false;
    buildInputs = [ pkgs.bitwarden-cli ];
    nativeBuildInputs = [ pkgs.ruff ];
    checkPhase = ''
      ruff check ${./${pname}.py}
      ruff format ${./${pname}.py} --exit-non-zero-on-format
    '';
    installPhase = ''
      install -Dm755 "${./${pname}.py}" "$out/bin/${pname}"
    '';
  };
in
{
  options.homelib.bitwarden= {
    enable = lib.mkEnableOption "bitwarden";
    enableGui = lib.mkEnableOption "bitwarden-desktop";
  };

  config = lib.mkIf cfg.enable {

    home.packages = [
      pkgs.bitwarden-cli
      createScript
    ] ++ lib.optionals cfg.enableGui [
      pkgs.bitwarden-desktop
    ];

  };
}
