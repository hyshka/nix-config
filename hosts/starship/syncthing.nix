{config, ...}: {
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
        "bryan-pixel4" = {id = "IUO5O7L-5CKMEZQ-4USKX7X-JTFZHZZ-3V6CBZE-4PQHMEU-TZXE7YN-FEDYMA2";};
        "tiny1" = {id = "SBU2DEZ-MEVLQ2S-2HN6L6N-3VILABR-Z3C5NWU-UD36AF7-4HVFWZ7-W2QJWQB";};
        "rg353ps" = {id = "7NUMEKY-IPM4SAT-HXKSGQP-KFBVHZO-PTSC5HW-CK5FBYL-HR5NKL6-KYQNXAY";};
        "renee-pixel7a" = {id = "KRD7T33-N5HKRSI-SA6NVWO-5D5ACZQ-5KD4SSU-MVFZZ3K-OOJA6BF-KWP4UA3";};
      };
      folders = {
        "Home Notes" = {
          id = "ljd5z-m6qfp";
          path = "/home/hyshka/Notes/Home Notes";
          devices = ["tiny1" "renee-pixel7a" "bryan-pixel4"];
        };
        "Notes" = {
          id = "36eka-bxxix";
          path = "/home/hyshka/Notes";
          devices = ["bryan-pixel4" "tiny1"];
        };
        "Finance" = {
          id = "4rqlm-lmagt";
          path = "/home/hyshka/Finance";
          devices = ["tiny1"];
        };
        "Videos" = {
          id = "xjkcs-vzunq";
          path = "/home/hyshka/Videos";
          devices = ["tiny1"];
        };
        "Documents" = {
          id = "vzqdy-afqjw";
          path = "/home/hyshka/Documents";
          devices = ["tiny1"];
        };
        "Music" = {
          id = "ijjkj-sfe6a";
          path = "/home/hyshka/Music";
          devices = ["tiny1"];
        };
        "Pictures" = {
          id = "nnvzz-njc6m";
          path = "/home/hyshka/Pictures";
          devices = ["tiny1"];
        };
        "Ansel" = {
          id = "euawy-suaeu";
          path = "/home/hyshka/Ansel";
          devices = ["tiny1"];
        };
        "Work" = {
          id = "dwgeq-drahv";
          path = "/home/hyshka/work";
          devices = ["tiny1"];
        };
        "Darktable" = {
          id = "4harq-seslg";
          path = "/home/hyshka/Darktable";
          devices = ["tiny1"];
        };
        "StardewValley_Saves" = {
          id = "j6n94-htfpu";
          path = "/home/hyshka/.config/StardewValley/Saves/";
          devices = ["tiny1" "rg353ps"];
        };
      };
    };
  };
}
