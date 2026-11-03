{
  programs.gamemode.enable = true;
  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };
  programs.steam = {
    enable = true;
    gamescopeSession = {
      enable = true;
      args = [
        "-W 1280"
        "-H 720"
        #"-F fsr"
        "-r 60"
        "-o 60"
        "-S integer"
        "-b"
        "-f"
      ];
    };
    protontricks.enable = true;
  };
}
