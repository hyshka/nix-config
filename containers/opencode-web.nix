{
  pkgs,
  lib,
  inputs,
  config,
  ...
}:
let
  container = import ./default.nix { inherit lib inputs; };
in
{
  imports = [ (container.mkContainer { name = "opencode-web"; }) ];

  sops.secrets.opencode-envFile = {
    sopsFile = ./secrets/opencode-web.yaml;
  };

  systemd.services.opencode-web = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = 5;
      ExecStart = "${
        lib.getExe inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode
      } web --hostname 0.0.0.0 --port 4096 --cors https://starship.tail7dfc7.ts.net";
      EnvironmentFile = config.sops.secrets.opencode-envFile.path;
    };
  };

  networking.firewall.allowedTCPPorts = [ 4096 ];

  environment.persistence."/persist" = {
    directories = [
      "/var/lib/private/opencode"
      "/root/" # global config at /root/.config/opencode
    ];
  };
}
