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
          detatched = [
            "${pkgs.util-linux}/bin/setsid ${pkgs.steam}/bin/steam steam://open/bigpicture"
          ];
        }
        {
          name = "Steam Gamescope Big Picture";
          image-path = "steam.png";
          detatched = [
            "${pkgs.util-linux}/bin/setsid ${pkgs.steam}/bin/steam-gamescope steam://open/bigpicture"
          ];
        }
      ];
    };
  };
}
