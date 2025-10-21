{ pkgs, ... }:
{
  # Accellerated video
  # https://nixos.wiki/wiki/Accelerated_Video_Playback
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      # this is for jasper lake
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      libvdpau-va-gl
    ];
  };
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  }; # Force intel-media-driver
}
