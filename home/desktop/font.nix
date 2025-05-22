{pkgs, ...}: {
  fontProfiles = {
    enable = true;
    # TODO: pkgs.nerd-fonts.iosevka-term
    monospace = {
      family = "Iosevka Comfy";
      package = pkgs.iosevka-comfy.comfy;
    };
    sans-serif = {
      family = "Iosevka Comfy Duo";
      package = pkgs.iosevka-comfy.comfy-duo;
    };
    serif = {
      family = "Iosevka Comfy Motion Duo";
      package = pkgs.iosevka-comfy.comfy-motion-duo;
    };
  };
}
