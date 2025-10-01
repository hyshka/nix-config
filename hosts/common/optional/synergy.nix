{ pkgs, ... }:
{
  # TODO: migrate to Deskflow: https://github.com/NixOS/nixpkgs/pull/346698
  services.synergy.server = {
    enable = false;
    # The port overrides the default port, 24800.
    address = "10.0.0.230";
    screenName = "ashyn";
    configFile = pkgs.writeText "synergy.conf" ''
      section: screens
          macbook:
          ashyn:
      end

      section: links
          ashyn:
              left = macbook
          macbook:
              right = ashyn
      end

      section: options
          keystroke(control+super+right) = switchInDirection(right)
          keystroke(control+super+left) = switchInDirection(left)
      end
    '';
    # TODO tls requires product key
    # tls.enable = false;
  };
}
