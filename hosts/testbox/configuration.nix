{ config, lib, pkgs, inputs, outputs, cfgLib, commonSettings, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../system
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "testbox";
  networking.networkmanager.enable = true;

  time.timeZone = commonSettings.localization.timezone;

  i18n.defaultLocale = commonSettings.localization.locale;
  console = {
    font = "Lat2-Terminus16";
    keyMap = commonSettings.localization.keymap;
  };

  sound.enable = true;
  isVmGuest = true;

  environment.systemPackages = with pkgs; [
    vim
    git

    (writeShellScriptBin "mount_repo" ''
      mkdir /home/${commonSettings.user.name}/localrepo
      sudo mount -t 9p -o trans=virtio,r repo /home/${commonSettings.user.name}/localrepo
    '')
  ];

  users.users.${commonSettings.user.name} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "libvirtd" ];
    initialPassword = "1234";
  };

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?

}

