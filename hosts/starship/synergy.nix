{pkgs, ...}: {
  services.synergy.server = {
    # TODO: over SSH or TLS
    enable = true;
    # default port is 24800
    address = "10.0.0.201";
    screenName = "starship";
    configFile = pkgs.writeText "synergy.conf" ''
      section: screens
          macbook:
          starship:
      end

      section: links
          starship:
              right = macbook

          macbook:
              left = starship
      end

      section: options
          keystroke(control+super+right) = switchInDirection(right)
          keystroke(control+super+left) = switchInDirection(left)
      end
    '';
  };
}
