{
  virtualisation.incus.enable = true;
  networking.nftables.enable = true;
  users.users.hyshka.extraGroups = ["incus-admin"];
  networking.firewall.interfaces.incusbr0.allowedTCPPorts = [
    53
    67
  ];
  networking.firewall.interfaces.incusbr0.allowedUDPPorts = [
    53
    67
  ];
}
