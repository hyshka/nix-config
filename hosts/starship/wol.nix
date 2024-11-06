# TODO
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
      ExecStart = "${pkgs.ethtool}/bin/ethtool -s eno1 wol g";
    };
    wantedBy = ["multi-user.target"];
  };
}
