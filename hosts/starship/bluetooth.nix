{
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  services.blueman.enable = true;
  # TODO: https://nixos.wiki/wiki/Bluetooth#USB_device_needs_to_be_unplugged.2Fre-plugged_after_suspend
}
