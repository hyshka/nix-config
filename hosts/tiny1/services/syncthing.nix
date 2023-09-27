{ pkgs, config, ... }:
{
  environment.systemPackages = with pkgs; [ syncthing ];

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

  networking.firewall.allowedTCPPorts = [ 22000 ];

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
      extraOptions = {
        defaults = {
	  folder = {
	    path = "/mnt/storage/hyshka/";
	    type = "receiveonly";
	  };
	};
      };
      devices = {
              "starship" = { id = "H2KQXW6-KBPZXXF-TDAWBJW-GZHGWEH-ZSLT7IN-N7CN2UB-TFY6KEH-CYLSXAC"; };
              "renee-galaxys9" = { id = "F6EBD2Q-TSSEF3J-YR4JH7L-ZHM6BQE-O7YOLSY-XKVHCSW-JUNM66E-YHDFWQK"; };
              "bryan-pixel4" = { id = "IUO5O7L-5CKMEZQ-4USKX7X-JTFZHZZ-3V6CBZE-4PQHMEU-TZXE7YN-FEDYMA2"; };
	      # TODO Bryan's old S9?
              "galaxys9" = { id = "RGNDH6P-UWJZ464-NSXPOQ6-SJE3V6S-GO6KDYC-3RI5NL4-HBWW25V-JVRS2AZ"; };
	      # TODO why was this in the old config?
              #"rpi4-nixos" = { id = "SBU2DEZ-MEVLQ2S-2HN6L6N-3VILABR-Z3C5NWU-UD36AF7-4HVFWZ7-W2QJWQB"; };
      };
      folders = {
              "Darktable" = {
                      id = "4harq-seslg";
                      path = "/mnt/storage/hyshka/Darktable";
                      devices = [ "starship" ];
                      type = "receiveonly";
              };
              "Music" = {
                      id = "ijjkj-sfe6a";
                      path = "/mnt/storage/hyshka/Music";
                      devices = [ "starship" ];
                      type = "receiveonly";
              };
              "Pictures" = {
                      id = "nnvzz-njc6m";
                      path = "/mnt/storage/hyshka/Pictures";
                      devices = [ "starship" ];
                      type = "receiveonly";
              };
              "Documents" = {
                      id = "vzqdy-afqjw";
                      path = "/mnt/storage/hyshka/Documents";
                      devices = [ "starship" ];
                      type = "receiveonly";
              };
              "Videos" = {
                      id = "xjkcs-vzunq";
                      path = "/mnt/storage/hyshka/Videos";
                      devices = [ "starship" ];
                      type = "receiveonly";
              };
              "Finance" = {
                      id = "4rqlm-lmagt";
                      path = "/mnt/storage/hyshka/Finance";
                      devices = [ "starship" ];
                      type = "receiveonly";
              };
              "Work" = {
                      id = "dwgeq-drahv";
                      path = "/mnt/storage/hyshka/work";
                      devices = [ "starship" ];
                      type = "receiveonly";
              };
              "Home Notes" = {
                      id = "ljd5z-m6qfp";
                      path = "/mnt/storage/hyshka/Home Notes";
                      devices = [ "starship" "renee-galaxys9" "bryan-pixel4" ];
                      type = "receiveonly";
              };
              "Phone Camera" = {
                      id = "sm-g930f_pwyw-photos";
                      path = "/mnt/storage/hyshka/phone-camera";
                      devices = [ "galaxys9" ];
                      type = "receiveonly";
              };
              "Phone Pictures" = {
                      id = "ti8iw-ywmhx";
                      path = "/mnt/storage/hyshka/Phone Pictures";
                      devices = [ "bryan-pixel4" ];
                      type = "receiveonly";
              };
      };
  };
}
