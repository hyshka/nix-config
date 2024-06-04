{
  pkgs,
  config,
  ...
}: {
  environment.systemPackages = with pkgs; [syncthing];

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

  networking.firewall.allowedTCPPorts = [22000];

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
          path = "/mnt/storage/hyshka/";
          type = "receiveonly";
        };
      };
      devices = {
        "starship" = {id = "Y5NGEPL-5ZSFMIJ-DR2NZZD-EYVGP7J-AZ4M2LY-ER7BZ4J-SXUNYVA-L2IJKQB";};
        "bryan-pixel4" = {id = "IUO5O7L-5CKMEZQ-4USKX7X-JTFZHZZ-3V6CBZE-4PQHMEU-TZXE7YN-FEDYMA2";};
        "rg353ps" = {id = "7NUMEKY-IPM4SAT-HXKSGQP-KFBVHZO-PTSC5HW-CK5FBYL-HR5NKL6-KYQNXAY";};
        "renee-pixel7a" = {id = "KRD7T33-N5HKRSI-SA6NVWO-5D5ACZQ-5KD4SSU-MVFZZ3K-OOJA6BF-KWP4UA3";};
      };
      folders = {
        "Ansel" = {
          id = "euawy-suaeu";
          path = "/mnt/storage/hyshka/Ansel";
          devices = ["starship"];
          type = "receiveonly";
        };
        "Darktable" = {
          id = "4harq-seslg";
          path = "/mnt/storage/hyshka/Darktable";
          devices = ["starship"];
          type = "receiveonly";
        };
        "Music" = {
          id = "ijjkj-sfe6a";
          path = "/mnt/storage/hyshka/Music";
          devices = ["starship"];
          type = "receiveonly";
        };
        "Pictures" = {
          id = "nnvzz-njc6m";
          path = "/mnt/storage/hyshka/Pictures";
          devices = ["starship"];
          type = "receiveonly";
        };
        "Documents" = {
          id = "vzqdy-afqjw";
          path = "/mnt/storage/hyshka/Documents";
          devices = ["starship"];
          type = "receiveonly";
        };
        "Videos" = {
          id = "xjkcs-vzunq";
          path = "/mnt/storage/hyshka/Videos";
          devices = ["starship"];
          type = "receiveonly";
        };
        "Finance" = {
          id = "4rqlm-lmagt";
          path = "/mnt/storage/hyshka/Finance";
          devices = ["starship"];
          type = "receiveonly";
        };
        "Work" = {
          id = "dwgeq-drahv";
          path = "/mnt/storage/hyshka/work";
          devices = ["starship"];
          type = "receiveonly";
        };
        "Home Notes" = {
          id = "ljd5z-m6qfp";
          path = "/mnt/storage/hyshka/Home Notes";
          devices = ["starship" "renee-pixel7a" "bryan-pixel4"];
          type = "sendreceive";
        };
        "Notes" = {
          id = "36eka-bxxix";
          path = "/mnt/storage/hyshka/Notes";
          devices = ["bryan-pixel4" "starship"];
          type = "sendreceive";
        };
        "Phone Camera" = {
          enable = false;
          id = "sm-g930f_pwyw-photos";
          path = "/mnt/storage/hyshka/phone-camera";
          devices = [];
          type = "receiveonly";
        };
        "Phone Pictures" = {
          id = "ti8iw-ywmhx";
          path = "/mnt/storage/hyshka/Phone Pictures";
          devices = ["bryan-pixel4"];
          type = "receiveonly";
        };
        "StardewValley_Saves" = {
          id = "j6n94-htfpu";
          path = "/mnt/storage/hyshka/StardewValley_Saves";
          devices = ["starship" "rg353ps"];
          type = "receiveonly";
        };
      };
    };
  };
}
