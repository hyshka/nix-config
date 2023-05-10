{ outputs, lib, ... }:
let
  hostnames = builtins.attrNames outputs.nixosConfigurations;
in
{
  programs.ssh = {
    enable = true;
    serverAliveInterval = 300;
    compression = true;
    #controlMaster = "auto";
    #controlPersist = "yes";
    #controlPath = "~/.ssh/sockets/socket-%r@%h:%p";
    #matchBlocks = {
    #  net = {
    #    host = builtins.concatStringsSep " " hostnames;
    #    forwardAgent = true;
    #    remoteForwards = [{
    #      bind.address = ''/%d/.gnupg-sockets/S.gpg-agent'';
    #      host.address = ''/%d/.gnupg-sockets/S.gpg-agent.extra'';
    #    }];
    #  };
    #};
  };
}
