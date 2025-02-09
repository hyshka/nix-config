{...}: {
  services.sunshine = {
    enable = true;
    openFirewall = true;
    capSysAdmin = true;
    # TODO
    #applications = {
    #  env = {
    #    PATH = "$(PATH):$(HOME)/.local/bin";
    #  };
    #  apps = [
    #    {
    #      name = "1440p Desktop";
    #      prep-cmd = [
    #        {
    #          do = "${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor output.DP-4.mode.2560x1440@144";
    #          undo = "${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor output.DP-4.mode.3440x1440@144";
    #        }
    #      ];
    #      exclude-global-prep-cmd = "false";
    #      auto-detach = "true";
    #    }
    #  ];
    #};
  };
  # Start sunshine app
  # kscreen-doctor output.DP-1.mode.${SUNSHINE_CLIENT_WIDTH}x${SUNSHINE_CLIENT_HEIGHT}@${SUNSHINE_CLIENT_FPS}
  # Stop app
  # kscreen-doctor output.DP-1.mode.2560x1440@240

  services.avahi = {
    enable = true;
    reflector = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      userServices = true;
      workstation = true;
    };
  };
}
