{ config, lib, nixpkgs-unstable, ... }:
let
  cfg = config.syslib.aistack;
in
{
  config = lib.mkIf cfg.enable {
    services.ollama = {
      enable = true;
      package = nixpkgs-unstable.ollama-rocm;
      port = cfg.ports.ollamaApi;
      loadModels = cfg.preloadModels;
      acceleration = "rocm";
      # rocmOverrideGfx = "10.3.0";
    };
  };
}
