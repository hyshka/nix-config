{
  pkgs,
  lib,
  ...
}:
let
  isLinux = pkgs.stdenv.isLinux;
in
{
  home.packages =
    with pkgs;
    [
      glances
      python313Packages.psutil
    ]
    ++ lib.optionals isLinux [ hddtemp ];

  programs.zsh.shellAliases = {
    glances = "glances --enable-plugin smart";
  };

  xdg.configFile = {
    "glances" = {
      text = ''
        [global]
        check_update=False

        [network]
        hide=lo,veth.*,br.*,docker.*

        [diskio]
        hide=loop.*

        [containers]
        disable=False

        [connections]
        disable=True

        [irq]
        disable=True
      '';
      target = "glances/glances.conf";
    };
  };
}
