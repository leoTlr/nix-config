{ pkgs }: 
let
  # nix hash to-sri sha256:$(nix-prefetch-url https://github.com/SylEleuth/gruvbox-plus-icon-pack/releases/download/v5.1/gruvbox-plus-icon-pack-5.1.zip --type sha256)
  link = "https://github.com/SylEleuth/gruvbox-plus-icon-pack/releases/download/v5.1/gruvbox-plus-icon-pack-5.1.zip";
in
  pkgs.stdenv.mkDerivation {
    name = "gruvbox-plus";

    src = pkgs.fetchurl {
      url = link;
      sha256 = "sha256-QB6QHBKUMXtXN6DYCCvMWJZtcFz4Al/XRlLhGibHcNg=";
    };

    dontUnpack = true;

    installPhase = ''
      mkdir -p $out
      ${pkgs.unzip}/bin/unzip $src -d $out/
    '';
  }
