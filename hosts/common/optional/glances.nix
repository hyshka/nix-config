{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    glances
    python310Packages.psutil
    hddtemp
  ];

  programs.zsh.shellAliases = {
    glances = "glances --enable-plugin smart";
  };

  environment.etc."glances/glances.conf" = {
    text = ''
      [global]
      check_update=False

      [network]
      hide=lo,wlan.*,docker.*

      [diskio]
      hide=loop.*

      [containers]
      disable=False

      [connections]
      disable=True

      [irq]
      disable=True
    '';
  };
}
