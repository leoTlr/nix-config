{config, lib, ...}:

{ 
  options.isVmGuest = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = {
    isVmGuest = true;
    services.qemuGuest.enable = true;
  };

}