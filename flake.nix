{
  description = "Personal config preferences";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  
  outputs = {self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
    nixosConfigurations = {
      testbox = nixpkgs.lib.nixosSystem {
        inherit system;
        inherit pkgs;
        
        modules = [
          home-manager.nixosModule {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
          ./hosts/testbox/configuration.nix
          ./users/leo/default.nix
          ./modules/hyprland/default.nix
        ];
      };
    };
  };
}