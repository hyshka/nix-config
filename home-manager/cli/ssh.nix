{ outputs, lib, pkgs, ... }:
let
  hostnames = builtins.attrNames outputs.nixosConfigurations;
in
{
  programs.ssh = {
    enable = true;
    serverAliveInterval = 300;
    compression = true;
    controlMaster = "auto";
    controlPersist = "3s";
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
      rpi4 = {
        host = "rpi4";
        hostname = "10.0.0.250";
	port = 38000;
	user = "hyshka";
      };
      # TODO not sure if I need this on mac
      #github = {
      #  host = "github";
      #  hostname = "github.com";
      #  user = "hyshka";
      #  identityFile = [ "~/.ssh/id_rsa" ];
      #  extraOptions = {
      #    AddKeysToAgent = "yes";
      #    UseKeychain = "yes";
      #  };
      #};
    };
  };
  home.packages = with pkgs; [
    sshfs
  ];
}
