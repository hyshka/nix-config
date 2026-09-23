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
  opencode = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode;
in
{
  # Do manual build first before deploying because openchamber-server requires network access
  # nix build ".#nixosConfigurations.openchamber.config.system.build.toplevel" --option sandbox false

  imports = [
    (container.mkContainer { name = "openchamber"; })
    inputs.openchamber-nix.nixosModules.default
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

  # sudo tailscale serve --bg --https=10000 http://localhost:8888
  # https://github.com/x13-me/openchamber-nix
  services.openchamber = {
    enable = true;
    port = 3000;
    host = "0.0.0.0";
    enableWebUI = true;
    lan = true;
    uiPasswordFile = config.sops.secrets.openchamber-password-file.path;
    opencodePackage = opencode;

    # opencodeHost = "http://hostname:4096";  # external OpenCode server (with skipOpencodeStart = true)
    # opencodePort = 4096;  # external OpenCode port (ignored when opencodeHost is set)
    # opencodeHostname = "127.0.0.1";  # bind hostname for the managed OpenCode server
    # skipOpencodeStart = true;  # use the external OpenCode server instead of spawning a managed one
    # verboseRequestLogs = true;  # log every request
    # skipApiCompression = true;  # skip API response compression
    # installCliForUser = false;  # skip putting the CLI on the service account's PATH (needed for LDAP/SSSD users)
    # settings = { };  # freeform attrs -> seeded into $OPENCHAMBER_DATA_DIR/settings.json on first start only (an existing non-empty file is never overwritten; delete it to re-seed)
  };

  # nix for running local builds
  nix = {
    enable = lib.mkForce true;
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = [
        "nix-command"
        "flakes"
        "ca-derivations"
      ];
    };
  };

  # Populate SSH key
  systemd.tmpfiles.rules = [
    "d /var/lib/openchamber/.ssh 0700 openchamber openchamber - -"
  ];

  # Fix system user ssh defaulting to /var/empty/.ssh/known_hosts
  users.users.openchamber.home = "/var/lib/openchamber";
  # System users default to pkgs.shadow (nologin); give it a usable shell
  users.users.openchamber.shell = pkgs.bashInteractive;

  systemd.services.openchamber = {
    environment = {
      # Expose system packages (incl. nix) on the sealed systemd PATH.
      PATH = lib.mkForce "/run/current-system/sw/bin";
      # Terminal/agent shells read $SHELL before falling back to /bin/sh.
      SHELL = lib.getExe pkgs.bashInteractive;
    };
    after = [ "sops-nix.service" ];
    # Populate SSH key
    serviceConfig.ExecStartPre = [
      (pkgs.writeShellScript "openchamber-ssh-pre" ''
        install -d -m 0700 -o openchamber -g openchamber /var/lib/openchamber/.ssh
        install -m 0600 -o openchamber -g openchamber ${openchamberPublicKeyFile} /var/lib/openchamber/.ssh/id_ed25519.pub
      '')
    ];
  };

  networking.firewall.allowedTCPPorts = [ 3000 ];

  environment.persistence."/persist" = {
    directories = [
      "/var/lib/openchamber"
    ];
  };
}
