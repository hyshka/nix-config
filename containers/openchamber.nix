{
  lib,
  inputs,
  config,
  pkgs,
  ...
}:
let
  container = import ./default.nix { inherit lib inputs; };
  openchamberPublicKeyFile = pkgs.writeText "openchamber_ed25519.pub" (
    builtins.readFile ./openchamber.pub
  );
in
{
  imports = [
    (container.mkContainer { name = "openchamber"; })
    inputs.openchamber-flake.nixosModules.default
  ];

  sops.secrets.openchamber-password-file = {
    sopsFile = ./secrets/openchamber.yaml;
  };

  sops.secrets.openchamber-ssh-key = {
    sopsFile = ./secrets/openchamber.yaml;
    owner = "openchamber";
    group = "openchamber";
    mode = "0600";
    path = "/var/lib/openchamber/.ssh/id_ed25519";
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/openchamber/.ssh 0700 openchamber openchamber - -"
  ];

  systemd.services.openchamber = {
    after = [ "sops-nix.service" ];
    environment.HOME = "/var/lib/openchamber";
    serviceConfig.ExecStartPre = [
      (pkgs.writeShellScript "openchamber-ssh-pre" ''
        install -d -m 0700 -o openchamber -g openchamber /var/lib/openchamber/.ssh
        install -m 0644 -o openchamber -g openchamber ${openchamberPublicKeyFile} /var/lib/openchamber/.ssh/id_ed25519.pub
      '')
    ];
  };

  # sudo tailscale serve --bg --https=10000 http://localhost:3000
  # https://github.com/zms-dev/openchamber-flake/blob/main/docs/NIXOS_OPTIONS.md
  services.openchamber = {
    enable = true;
    port = 3000;
    host = "0.0.0.0";
    uiPasswordFile = config.sops.secrets.openchamber-password-file.path;
    extraEnvironment = {
      OPENCHAMBER_TERMINAL_SHELL = "/run/current-system/sw/bin/bash";
    };

    #settings = {
    #  themeVariant = "dark";
    #  darkThemeId = "default";
    #  desktopLanAccessEnabled = false;
    #  showReasoningTraces = true;
    #};
  };

  # nix for running local builds
  nix = {
    enable = lib.mkForce true;
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes ca-derivations";
    };
  };

  # Expose system packages (incl. nix) on the sealed systemd PATH.
  systemd.services.openchamber.environment.PATH = lib.mkForce "/run/current-system/sw/bin";

  # Allow bash for terminal execution
  users.users.openchamber.shell = pkgs.bash;

  networking.firewall.allowedTCPPorts = [ 3000 ];

  environment.persistence."/persist" = {
    directories = [
      "/var/lib/openchamber"
    ];
  };
}
