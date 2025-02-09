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
      # Phone res 1080 x 2280 pixels, 19:9 ratio
      # TODO: read SUNSHINE_CLIENT_WIDTH SUNSHINE_CLIENT_HEIGHT SUNSHINE_CLIENT_FPS
      args = [
        "-W 1280"
        "-H 720"
        #"-F fsr"
        #"-w 2280"
        #"-h 1080"
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
