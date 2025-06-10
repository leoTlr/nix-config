{
  description = "Personal config preferences";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-colors.url = "github:misterio77/nix-colors";
    hyprcursor-phinger ={
      url = "github:jappie3/hyprcursor-phinger";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, ... }:
  let
    cfgLib = import ./cfglib.nix { inherit (self) inputs; };
  in
    with cfgLib; {

      nixosConfigurations = {
        t14 = mkSystem "t14" "leo";
        bee = mkSystem "bee" "leo";
        liveiso = mkSystem "liveiso" "leo";
        sparrow = mkSystem "sparrow" "leo";
      };

      homeConfigurations = {
        "leo@t14" = mkHome "x86_64-linux" "t14" "leo";
        "ji09br@APM3LJDY9D2K7HC" = mkHome "aarch64-darwin" "APM3LJDY9D2K7HC" "ji09br";
        "deck@deck" = mkHome "x86_64-linux" "deck" "deck";
      };

      packages."x86_64-linux".liveiso = self.nixosConfigurations.liveiso.config.system.build.images.iso-installer;

    };
}
