{
  config,
  pkgs,
  ...
}:
let
  textfileDir = "/var/lib/prometheus-node-exporter-text-files";
in
{
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
    config.services.prometheus.exporters.node.port
  ];

  services.prometheus.exporters.node = {
    enable = true;
    listenAddress = "0.0.0.0";
    enabledCollectors = [ "systemd" ];
    extraFlags = [ "--collector.textfile.directory=${textfileDir}" ];
  };

  systemd.tmpfiles.rules = [
    "d ${textfileDir} 0775 root root -"
  ];

  system.activationScripts.node-exporter-system-version = ''
    (
      cd ${textfileDir}
      (
        echo -n "system_version ";
        readlink /nix/var/nix/profiles/system | cut -d- -f2
      ) > system-version.prom.next
      mv system-version.prom.next system-version.prom
    )
  '';

  systemd.services.rpi-health = {
    description = "Write Raspberry Pi health metrics";
    serviceConfig.Type = "oneshot";
    script = ''
      throttled=$(${pkgs.libraspberrypi}/bin/vcgencmd get_throttled | cut -d= -f2)
      mmc=$(${pkgs.util-linux}/bin/dmesg | ${pkgs.gnugrep}/bin/grep -cE 'mmc0.*(error|timeout)' || true)
      cat > ${textfileDir}/rpi.prom.next <<EOF
      # HELP rpi_throttled Bitmask from vcgencmd get_throttled
      # TYPE rpi_throttled gauge
      rpi_throttled $((throttled))
      # HELP rpi_mmc0_messages dmesg lines reporting an SD card error
      # TYPE rpi_mmc0_messages gauge
      rpi_mmc0_messages $mmc
      EOF
      mv ${textfileDir}/rpi.prom.next ${textfileDir}/rpi.prom
    '';
  };

  systemd.timers.rpi-health = {
    wantedBy = [ "timers.target" ];
    timerConfig.OnCalendar = "*:0/5";
  };
}
