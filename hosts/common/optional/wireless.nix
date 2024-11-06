{...}: {
  hardware.bluetooth = {
    enable = true;
  };

  # Wireless secrets stored through sops
  #sops.secrets.wireless = {
  #  sopsFile = ../secrets.yaml;
  #  neededForUsers = true;
  #};

  # TODO: networking.wireless
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
}
