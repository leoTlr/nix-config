{ config, lib, ... }:

{
  options.syslib.pipewire.enable = lib.mkEnableOption "pipewire";

  config = lib.mkIf config.syslib.pipewire.enable {
    
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };

    # use realtime kernel features for less sound latency
    # security.rtkit.enable = true;

  };
  
}