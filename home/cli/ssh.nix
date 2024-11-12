{
  programs.ssh = {
    enable = true;
    serverAliveInterval = 300;
    compression = true;
    controlMaster = "auto";
    controlPersist = "3s";
    matchBlocks = {
      # Force gpg-agent to open in current terminal
      # Match host * exec "gpg-connect-agent UPDATESTARTUPTTY /bye"
      # https://wiki.archlinux.org/title/GnuPG#Configure_pinentry_to_use_the_correct_TTY
      gpg = {
        match = ''host * exec "gpg-connect-agent UPDATESTARTUPTTY /bye"'';
      };

      # These are only accessible within the tailnet
      tiny1 = {
        host = "tiny1";
        hostname = "tiny1";
        user = "hyshka";
      };
      rpi4 = {
        host = "rpi4";
        hostname = "rpi4";
        user = "hyshka";
      };
      starship = {
        host = "starship";
        hostname = "starship";
        user = "hyshka";
      };
      ashyn = {
        host = "ashyn";
        hostname = "ashyn";
        user = "hyshka";
      };
    };
  };
}
