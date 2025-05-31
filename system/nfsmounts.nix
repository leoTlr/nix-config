{ config, lib, ... }:
let
  cfg = config.syslib.nfsmounts;

  mkMountAttrs = mountDef:
  let
    split = lib.splitString ":" mountDef;
    host = builtins.elemAt split 0;
    remotePath = builtins.elemAt split 1;
    localPath = builtins.elemAt split 2;
  in {
    type = "nfs";
    mountConfig.Options = "noatime,rw,nconnect=16";
    what = "${host}:${remotePath}";
    where = localPath;
  };
in
{
  options.syslib.nfsmounts = with lib; {
    enable = mkEnableOption "nfsmounts";
    mounts = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "values of type 'host:/remote/path:/mount/path'";
    };
  };

  config = lib.mkIf cfg.enable {

    assertions = [{
      assertion = !lib.any (mountDef: lib.length (lib.splitString ":" mountDef) != 3) cfg.mounts;
      message = "mount definition has to be of type: 'host:/remote/path:/mount/path' with exactly two ':'";
    }];

    boot = {
      supportedFilesystems = [ "nfs" ];
      kernelModules = [ "nfs" ];
    };
    # boot.initrd = {
    #   supportedFilesystems = [ "nfs" ];
    #   kernelModules = [ "nfs" ];
    # };
    services.rpcbind.enable = true;

    systemd.mounts = builtins.map mkMountAttrs cfg.mounts;

    # systemd.automounts = [{
    #   wantedBy = [ "multi-user.target" ];
    #   automountConfig.TimeoutIdleSec = "600";
    #   where = "/mnt/relaxo/nedia";
    # }];
  };
}
