{
  description = "Personal config preferences";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    # home-manager = {
    #   url = "github:nix-community/home-manager";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };
  
  outputs = {self, nixpkgs, ... }:
    let
      lib = nixpkgs.lib; 
    in {
    nixosConfigurations = {
      testbox = lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ 
          ./configuration.nix
          # inputs.home-manager.nixosModules.default 
        ];
      };
    };
  };
}