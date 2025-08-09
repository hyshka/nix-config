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
          name = "Steam (1440p)";
          image-path = "steam.png";
          detached = [
            "${pkgs.util-linux}/bin/setsid ${pkgs.steam}/bin/steam steam://open/bigpicture"
          ];
          prep-cmd = [
            {
              undo = "${pkgs.util-linux}/bin/setsid ${pkgs.steam}/bin/steam steam://close/bigpicture";
            }
          ];
        }
        {
          name = "Steam (480p)";
          image-path = "steam.png";
          detached = [
            "${pkgs.util-linux}/bin/setsid ${pkgs.steam}/bin/steam steam://open/bigpicture"
          ];
          prep-cmd = [
            {
              # TODO: ${SUNSHINE_CLIENT_WIDTH}x${SUNSHINE_CLIENT_HEIGHT}@${SUNSHINE_CLIENT_FPS}
              do = "${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor output.DP-1.mode.640x480@60";
              undo = "${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor output.DP-1.mode.2560x1440@240 && ${pkgs.util-linux}/bin/setsid ${pkgs.steam}/bin/steam steam://close/bigpicture";
            }
          ];
        }
        {
          name = "Steam Gamescope (480p)";
          image-path = "steam.png";
          detached = [
            "setsid steam-gamescope"
          ];
          prep-cmd = [
            {
              # TODO: ${SUNSHINE_CLIENT_WIDTH}x${SUNSHINE_CLIENT_HEIGHT}@${SUNSHINE_CLIENT_FPS}
              do = "${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor output.DP-1.mode.640x480@60";
              undo = "${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor output.DP-1.mode.2560x1440@240 && ${pkgs.util-linux}/bin/setsid ${pkgs.steam}/bin/steam steam://close/bigpicture";
            }
          ];
        }
      ];
    };
  };
}
