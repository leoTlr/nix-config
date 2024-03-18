{config, lib, ...}:

{ 
  options.isVmGuest = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Treat this host as VM-guest";
  };

  config = lib.mkIf config.isVmGuest {
    services.qemuGuest.enable = true;
  };

}