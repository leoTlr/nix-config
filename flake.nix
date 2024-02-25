{
  description = "Personal config preferences";
  
  inputs = {
    
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-colors.url = "github:misterio77/nix-colors";

  };
  
  outputs = { ... }@inputs :
    let
      cfgLib = import ./cfglib.nix { inherit inputs commonSettings; };

      # shared between system and homeManager configs
      commonSettings = {

        localization = {
          locale = "en_IE.UTF-8";
          timezone = "Europe/Berlin";
          keymap = "de";
        };

        user = {
          name = "leo";
        };

      };
    in 
      with cfgLib; {

        homeManagerModules.default = ./user;
        nixosModules.default = ./system;

        nixosConfigurations = {
          inherit cfgLib;
          inherit commonSettings;
          testbox = mkSystem ./hosts/testbox/configuration.nix;
        };

        homeConfigurations = {
          "leo" = mkHome "x86_64-linux" ./hosts/testbox/home.nix;
        };
      };
}