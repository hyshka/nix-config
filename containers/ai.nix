{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ radeontop ];

  services.open-webui = {
    enable = true;
    openFirewall = true;
    environment = {
      OLLAMA_BASE_URL = "http://127.0.0.1:11434";
    };
    #environmentFile = '';
  };

  services.ollama = {
    enable = true;
    openFirewall = true;
    # Optional: preload models, see https://ollama.com/library
    #loadModels = [ "llama3.2:3b" "deepseek-r1:1.5b"];
    package = pkgs.ollama-rocm;
    rocmOverrideGfx = "10.3.0";
    acceleration = "rocm";
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
