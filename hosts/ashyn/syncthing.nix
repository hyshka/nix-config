{ config, ... }:
{
  sops.secrets = {
    syncthing_key = {
      owner = config.users.users.hyshka.name;
      group = config.users.users.hyshka.group;
    };
    syncthing_cert = {
      owner = config.users.users.hyshka.name;
      group = config.users.users.hyshka.group;
    };
  };

  services.syncthing = {
    enable = true;
    dataDir = "/home/hyshka";
    configDir = "/home/hyshka/.config/syncthing";
    user = "hyshka";
    group = "users";
    overrideDevices = true;
    overrideFolders = true;
    key = config.sops.secrets.syncthing_key.path;
    cert = config.sops.secrets.syncthing_cert.path;
    settings = {
      defaults = {
        folder = {
          path = "/home/hyshka/";
        };
      };
      devices = {
        "bryan-pixel4" = {
          id = "IUO5O7L-5CKMEZQ-4USKX7X-JTFZHZZ-3V6CBZE-4PQHMEU-TZXE7YN-FEDYMA2";
        };
        "tiny1" = {
          id = "SBU2DEZ-MEVLQ2S-2HN6L6N-3VILABR-Z3C5NWU-UD36AF7-4HVFWZ7-W2QJWQB";
        };
        "starship" = {
          id = "Y5NGEPL-5ZSFMIJ-DR2NZZD-EYVGP7J-AZ4M2LY-ER7BZ4J-SXUNYVA-L2IJKQB";
        };
      };
      folders = {
        "Logseq" = {
          id = "uogke-lyndg";
          path = "/home/hyshka/Logseq";
          devices = [
            "starship"
            "tiny1"
            "bryan-pixel4"
          ];
        };
      };
    };
  };
}
