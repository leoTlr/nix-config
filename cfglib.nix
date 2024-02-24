{ inputs, commonSettings, ... }@args:
let
  inherit (inputs) cfgLib;
  inherit (inputs.self) outputs;
  pkgsFor = sys: inputs.nixpkgs.legacyPackages.${sys};
in
{
  
  mkSystem = hostconfig:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs outputs commonSettings; };
      modules = [
        hostconfig
        outputs.nixosModules.default
      ];
    };

  mkHome = sys: config:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = pkgsFor sys;
      extraSpecialArgs = { 
        inherit inputs outputs;
        commonSettings = commonSettings // { system.arch = sys; };
      };
      modules = [
        config
        outputs.homeManagerModules.default
      ];
    };

}