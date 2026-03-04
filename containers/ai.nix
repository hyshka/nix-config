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

  # Set up
  # - incus config device add ai persist disk "source=/persist/ai" "path=/persist" "shift=true"
  # - incus config device add ai gpu gpu pci=0000:2b:00.0

  environment.systemPackages = with pkgs; [ radeontop ];

  services.open-webui = {
    enable = true;
    openFirewall = true;
    host = "0.0.0.0";
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
    host = "0.0.0.0";
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
      "/var/lib/private/open-webui"
      "/var/lib/private/ollama"
    ];
  };
}
