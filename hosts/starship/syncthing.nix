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
        "rg353ps" = {
          id = "U4UPYDR-LVN7VTQ-3SOLQWP-QJFRKKN-IWGOXZR-2YOFOZL-OFEGGYA-ZMC6HAS";
        };
        "renee-pixel7a" = {
          id = "KRD7T33-N5HKRSI-SA6NVWO-5D5ACZQ-5KD4SSU-MVFZZ3K-OOJA6BF-KWP4UA3";
        };
        "ashyn" = {
          id = "YPGYO6J-3JUHLKP-ZHGEUFE-WCG2VWT-KHQ3HGV-MMSGGZF-2WXXVMC-6DT2ZQA";
        };
      };
      folders = {
        "Documents" = {
          id = "vzqdy-afqjw";
          path = "/home/hyshka/Documents";
          devices = [ "tiny1" ];
        };
        "Music" = {
          id = "ijjkj-sfe6a";
          path = "/home/hyshka/Music";
          devices = [ "tiny1" ];
        };
        "Ansel" = {
          id = "euawy-suaeu";
          path = "/home/hyshka/Ansel";
          devices = [ "tiny1" ];
        };
        "Work" = {
          id = "dwgeq-drahv";
          path = "/home/hyshka/work";
          devices = [ "tiny1" ];
        };
        "Darktable" = {
          id = "4harq-seslg";
          path = "/home/hyshka/Darktable";
          devices = [ "tiny1" ];
        };
        # TODO: automate symlink for stardew saves
        # ln -s ~/Games/Roms/ports/stardewvalley/savedata/Saves ~/.config/StardewValley/Saves
        # https://nix-community.github.io/home-manager/options.xhtml#opt-home.file
        "Roms" = {
          id = "xgy3x-u2fhw";
          path = "/home/hyshka/Games/Roms/";
          devices = [
            "tiny1"
            "rg353ps"
          ];
        };
        "Logseq" = {
          id = "uogke-lyndg";
          path = "/home/hyshka/Logseq";
          devices = [
            "ashyn"
            "tiny1"
            "bryan-pixel4"
          ];
        };
      };
    };
  };
}
