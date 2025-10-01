{ pkgs, ... }:
let
  interface = "enp37s0";
in
{
  systemd.services.wol = {
    enable = true;
    description = "Wake on LAN";
    unitConfig = {
      Requires = "network.target";
      After = "network.target";
    };
    serviceConfig = {
      Type = "oneshot";
      ExecStart = ''
        ${pkgs.ethtool}/bin/ethtool -s ${interface} wol g
      '';
    };
    wantedBy = [ "multi-user.target" ];
  };
}
