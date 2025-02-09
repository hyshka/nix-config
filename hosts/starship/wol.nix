{pkgs, ...}: {
  systemd.services.wol = {
    enable = true;
    description = "Wake on LAN";
    unitConfig = {
      Requires = "network.target";
      After = "network.target";
    };
    serviceConfig = {
      Type = "oneshot";
      # Enable WoL on both physical and tailscale interfaces
      ExecStart = ''
        ${pkgs.ethtool}/bin/ethtool -s enp37s0 wol g
        ${pkgs.ethtool}/bin/ethtool -s tailscale0 wol g
      '';
    };
    wantedBy = ["multi-user.target"];
  };
}
