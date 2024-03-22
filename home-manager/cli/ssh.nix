{
  outputs,
  lib,
  pkgs,
  ...
}: let
  hostnames = builtins.attrNames outputs.nixosConfigurations;
in {
  programs.ssh = {
    enable = true;
    serverAliveInterval = 300;
    compression = true;
    controlMaster = "auto";
    controlPersist = "3s";
    # TODO mkdir -p ~/.ssh/master-socket required before this will work
    controlPath = "~/.ssh/master-socket/%r@%h:%p";
    matchBlocks = {
      # Force gpg-agent to open in current terminal
      # Match host * exec "gpg-connect-agent UPDATESTARTUPTTY /bye"
      # https://wiki.archlinux.org/title/GnuPG#Configure_pinentry_to_use_the_correct_TTY
      gpg = {
        match = ''host * exec "gpg-connect-agent UPDATESTARTUPTTY /bye"'';
      };

      #  net = {
      #    host = builtins.concatStringsSep " " hostnames;
      #    forwardAgent = true;
      #    remoteForwards = [{
      #      bind.address = ''/%d/.gnupg-sockets/S.gpg-agent'';
      #      host.address = ''/%d/.gnupg-sockets/S.gpg-agent.extra'';
      #    }];
      #  };
      tiny1 = {
        host = "tiny1";
        hostname = "10.0.0.240";
        port = 38000;
        user = "hyshka";
      };
      tiny1Ex = {
        host = "tiny1Ex";
        hostname = "68.148.153.144";
        port = 38000;
        user = "hyshka";
      };
      rpi4 = {
        host = "rpi4";
        hostname = "10.0.0.250";
        port = 38002;
        user = "hyshka";
      };
      rpi4w = {
        host = "rpi4w";
        hostname = "10.0.0.241";
        port = 38002;
        user = "hyshka";
      };
      rpi4Ex = {
        host = "rpi4Ex";
        hostname = "10.0.0.250";
        port = 38002;
        user = "hyshka";
        proxyJump = "hyshka@68.148.153.144:38000";
      };
      starship = {
        host = "starship";
        hostname = "10.0.0.251";
        port = 38001;
        user = "hyshka";
        proxyJump = "hyshka@10.0.0.250:38000";
      };
      starshipEx = {
        host = "starshipEx";
        hostname = "10.0.0.251";
        port = 38001;
        user = "hyshka";
        proxyJump = "hyshka@68.148.153.144:38000";
      };
    };
  };
}
