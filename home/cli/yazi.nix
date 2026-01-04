{ pkgs, ... }:
{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    extraPackages = with pkgs; [
      ffmpeg # video thumbs
      poppler # (for PDF preview)
      p7zip # (for archive extraction and preview, requires non-standalone version)
      zoxide # (for historical directories navigation, requires fzf)
      resvg # (for SVG preview)
      imagemagick # (for Font, HEIC, and JPEG XL preview, >= 7.1.1)
      wl-clipboard # (for Linux clipboard support)
      # Configured in other modules:
      # fzf (for quick file subtree navigation, >= 0.53.0)
      # rg (for file content searching)
      # jq json preview
      # fd (for file searching)
    ];
  };
}
