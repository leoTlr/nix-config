{ config, lib, pkgs, ... }:
let
  cfg = config.syslib.resourceControl;

  hostcriticalSliceConfig = {
    ManagedOOMMemoryPressure = "omit";
    MemoryMin = "384M";
    IOWeight = 1000; # default 100
    CPUWeight = 1000; # default 100
  };

  stresstest = pkgs.writeShellApplication {
    name = "stresstest";
    runtimeInputs = [ pkgs.stress-ng pkgs.gawk ];
    text = ''
      slice=''${1:?no slice given}
      memory_available=$(grep MemTotal /proc/meminfo | awk '{print $2}')
      memory_stress=$(( $(( memory_available * 120 )) / 100 ))
      echo "''${memory_stress}K"
      systemd-run --slice="''${slice}" -- \
        stress-ng --all 4 --timeout 2m --vm-bytes="''${memory_stress}K"
      journalctl -f | grep -i oom
    '';
  };

in
{
  options.syslib.resourceControl.enable = lib.mkEnableOption "custom resourceControl";

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ stresstest ];

    systemd = {

      oomd = {
        enable = true;
        enableRootSlice = true;
        enableSystemSlice = true;
        enableUserSlices = true;
      };

      slices = {

        hostcritical = {
          description = "stuff that always has prio";
          sliceConfig = hostcriticalSliceConfig;          
        };

        # root shells
        "user-0".sliceConfig = hostcriticalSliceConfig;
        
        workload = {
          description = "slice for the apps that this host shall provide";
          sliceConfig = {
            ManagedOOMMemoryPressure = "kill";
            IOWeight = 150;
            CPUWeight = 150;
          };
        };

        # default slice for system units
        system.sliceConfig = {
          ManagedOOMMemoryPressure = "kill";
          IOWeight = 100;
          CPUWeight = 100;
        };

        lowprio = {
          description = "least important services";
          sliceConfig = {
            ManagedOOMMemoryPressure = "kill";
            IOWeight = 10;
            CPUWeight = 10;
          };
        };
         
      };

      services = {
        sshd.serviceConfig.Slice = "hostcritical.slice";
        systemd-oomd.serviceConfig.Slice = "hostcritical.slice";
        systemd-journald.serviceConfig.Slice = "hostcritical.slice";
        nix-daemon.serviceConfig.Slice = "lowprio.slice";
      };
      
    };

  };
}
