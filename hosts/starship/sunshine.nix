{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # TODO: https://nixos.org/manual/nixos/stable/options#opt-services.sunshine.enable
    sunshine
    xorg.xrandr # required for sunshine
    util-linux # required for sunshine/setsid
  ];

  networking.firewall.allowedTCPPorts = [
    47989 # streaming
    47990 # web ui
  ];

  # Enable avahi for Sunshine
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
  services.udev.extraRules = ''
    KERNEL=="uinput", SUBSYSTEM=="misc", OPTIONS+="static_node=uinput", TAG+="uaccess"
  '';

  # Enable KMS access for Sunshine
  security.wrappers.sunshine = {
    owner = "root";
    group = "root";
    capabilities = "cap_sys_admin+ep";
    source = "${pkgs.sunshine}/bin/sunshine";
  };
  systemd.user.services.sunshine = {
    enable = false;
    script = "/run/current-system/sw/bin/env /run/wrappers/bin/sunshine";

    unitConfig = {
      Description = "Sunshine is a Game stream host for Moonlight.";
      StartLimitIntervalSec = 500;
      StartLimitBurst = 5;
    };

    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "5s";
      #ExecStart = "${config.security.wrapperDir}/sunshine";
    };
    wantedBy = ["graphical-session.target"];
  };
}
