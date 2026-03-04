{
  pkgs,
  lib,
  inputs,
  ...
}:
let
  container = import ./default.nix { inherit lib inputs; };
in
{
  imports = [ (container.mkContainer { name = "ai"; }) ];

  environment.systemPackages = with pkgs; [ radeontop ];

  services.open-webui = {
    enable = true;
    openFirewall = true;
    environment = {
      OLLAMA_BASE_URL = "http://127.0.0.1:11434";
    };
    #environmentFile = '';
  };

  nixpkgs = {
    config.allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) [
        "open-webui"
      ];
  };

  services.ollama = {
    enable = true;
    openFirewall = true;
    # Optional: preload models, see https://ollama.com/library
    #loadModels = [ "llama3.2:3b" "deepseek-r1:1.5b"];
    package = pkgs.ollama-rocm;
    rocmOverrideGfx = "10.3.0";
    environmentVariables = {
      HCC_AMDGPU_TARGET = "gfx1030";
    };
  };

  environment.persistence."/persist" = {
    directories = [
      "/var/lib/open-webui"
      "/var/lib/ollama"
    ];
  };
}
