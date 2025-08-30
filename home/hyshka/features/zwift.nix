# https://github.com/netbrain/zwift
# Also:
# - xdg desktop: https://github.com/nodu/nixos-baremetal/blob/cb9decf7aa8e4f08f82e2c7a0628f53b9a2419e3/home/home-manager.nix#L266
# - script as flake: https://github.com/nikolaiser/dungeon/blob/cfcbdc437b4d84888ccc9313559dfa56d095d903/nixos/modules/gaming/home/zwift.nix#L8
# - home manager module: https://github.com/wesnel/nix-config/blob/1fdb2e03eb5b37927201f30a0be8718516a5042f/modules/home-manager/zwift/default.nix#L21
{pkgs, ...}: {
  home.sessionPath = ["$HOME/.local/bin"];
  home.file = {
    "zwift.sh" = {
      source = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/netbrain/zwift/c17f3d180113b6934d84a9b92d0c6ccd932e2c6c/zwift.sh";
        hash = "sha256-2VH+SaX1k7L52eq8RhczD2yjq+tpu3u9m29EI6VX5DM=";
      };
      target = ".local/bin/zwift";
      executable = true;
    };
  };
  # TODO
  xdg.configFile = {
    "zwift" = {
      text = ''
        ZWIFT_USERNAME=username
        ZWIFT_PASSWORD=password
      '';
      target = "zwift/config";
    };
  };
}
