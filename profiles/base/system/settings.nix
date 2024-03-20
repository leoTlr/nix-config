{ config, pkgs, ... }:
let 
  cfg = config.profiles.base;
in
{
  system.stateVersion = cfg.system.stateVersion;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    inherit (cfg.system) hostName;
    networkmanager.enable = true;
  };

  time.timeZone = cfg.localization.timezone;

  i18n.defaultLocale = cfg.localization.locale;
  console = {
    font = "Lat2-Terminus16";
    keyMap = cfg.localization.keymap;
  };
  customFonts.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    git

    (writeShellScriptBin "mount_repo" ''
      mkdir /home/${cfg.system.mainUserName}/localrepo
      sudo mount -t 9p -o trans=virtio,r repo /home/${cfg.system.mainUserName}/localrepo
    '')
  ];

  users.users.${cfg.system.mainUserName} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "libvirtd" ];
    initialPassword = "1234"; # to be changed on first login
  };

}