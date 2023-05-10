{ pkgs, ... }: {
  fontProfiles = {
    enable = true;
    monospace = {
      family = "Iosevka";
      package = pkgs.iosevka-comfy.comfy;
    };
    sans-serif = {
      family = "Iosevka";
      package = pkgs.iosevka-comfy.comfy-duo;
    };
    serif = {
      family = "Iosevka";
      package = pkgs.iosevka-comfy.comfy-motion-duo;
    };
  };
}
