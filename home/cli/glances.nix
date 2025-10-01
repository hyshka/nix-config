{ pkgs, ... }:
{
  home.packages = with pkgs; [ glances ];

  xdg.configFile = {
    "glances" = {
      text = ''
        [global]
        check_update=False

        [network]
        hide=veth.*,br.*

        [diskio]
        hide=loop.*

        [connections]
        disable=True

        [irq]
        disable=True
      '';
      target = "glances/glances.conf";
    };
  };
}
