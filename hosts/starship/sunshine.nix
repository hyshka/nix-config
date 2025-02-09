{pkgs, ...}: {
  services.sunshine = {
    enable = true;
    openFirewall = true;
    capSysAdmin = true;
    applications = {
      apps = [
        {
          name = "Desktop";
          image-path = "desktop.png";
        }
        {
          name = "Steam Big Picture";
          image-path = "steam.png";
          detached = [
            "${pkgs.util-linux}/bin/setsid ${pkgs.steam}/bin/steam steam://open/bigpicture"
          ];
        }
        {
          name = "Steam Gamescope";
          image-path = "steam.png";
          output = "/home/hyshka/steam.txt";
          detached = [
            "setsid steam-gamescope"
          ];
          prep-cmd = [
            {
              # TODO: ${SUNSHINE_CLIENT_WIDTH}x${SUNSHINE_CLIENT_HEIGHT}@${SUNSHINE_CLIENT_FPS}
              do = "${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor output.DP-1.mode.1280x720@60";
              undo = "${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor output.DP-1.mode.2560x1440@240";
            }
          ];
        }
      ];
    };
  };
}
