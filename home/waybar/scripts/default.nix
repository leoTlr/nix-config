{ pkgs }:
let
  # mkWaybarScript = name: deps:
  #   pkgs.writeShellApplication {
  #     inherit name;
  #     text = builtins.readFile (./. + "/${name}.sh");
  #     runtimeInputs = deps;
  #   };

  mkWaybarPythonScript = name:
    pkgs.writers.writePython3Bin name {} (builtins.readFile (./. + "/${name}.py"));

  scripts = [
    (mkWaybarPythonScript "waybar-systemd-indicator")
  ];
in

pkgs.symlinkJoin {
  name = "waybar-scripts";
  paths = scripts;
}
