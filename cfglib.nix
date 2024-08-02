{ inputs, commonSettings, ... }:
let
  inherit (inputs.self) outputs;
  pkgsFor = sys: inputs.nixpkgs.legacyPackages.${sys};
in
{

  mkSystem = configName:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs outputs commonSettings configName; };
      modules = [
        (./. + "/hosts/${configName}/configuration.nix")
        outputs.nixosModules.default
      ];
    };

  mkHome = sys: configName:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = pkgsFor sys;
      extraSpecialArgs = {
        inherit inputs outputs configName;
        commonSettings = commonSettings // { system.arch = sys; };
      };
      modules = [
        (./. + "/hosts/${configName}/home.nix")
        outputs.homeManagerModules.default
      ];
    };

}