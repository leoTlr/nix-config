{
  description = "Personal config preferences";
  
  inputs = {
    
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };
  
  outputs = { self, nixpkgs, home-manager, ... }:
    let
      
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

    in {
      
      nixosConfigurations = {
        testbox = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [ ./hosts/testbox/configuration.nix ];
        };
      };

      homeConfigurations = {
        leo = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [./hosts/testbox/home.nix ];
          };
      };

    };
  
}