{ pkgs, ... }:
{
  # Accellerated video
  # https://nixos.wiki/wiki/Accelerated_Video_Playback
  # this is for jasper lake
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-compute-runtime
      vpl-gpu-rt
    ];
  };
}
