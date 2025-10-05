{ config, lib, ... }:
let
  cfg = config.syslib.aistack;
in
{
  config = lib.mkIf cfg.enable {
    services.ollama = {
      enable = true;
      port = cfg.ports.ollamaApi;
      loadModels = cfg.preloadModels;
      acceleration = "rocm";
      # rocmOverrideGfx = "10.3.0";
    };
  };
}
