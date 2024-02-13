{ config, lib, pkgs, localeSettings, userSettings, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];
  
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "testbox";
  networking.networkmanager.enable = true;

  time.timeZone = localeSettings.timezone;

  i18n.defaultLocale = localeSettings.locale;
  console = {
    font = "Lat2-Terminus16";
    keyMap = localeSettings.keymap;
  };

  sound.enable = true;
  hardware.pulseaudio.enable = true;
  virtualisation.libvirtd.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    git
    libvirt # testbox
    opentofu # testbox
  ];

  users.users.${userSettings.name} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "libvirtd" ];
    initialPassword = "1234";
    # packages = with pkgs; [
    #   foo
    # ];
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

