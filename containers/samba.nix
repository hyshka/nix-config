{
  lib,
  inputs,
  config,
  pkgs,
  ...
}: let
  container = import ./default.nix {inherit lib inputs;};
in
  container.mkContainer {
    name = "samba";
  }
  // {
    # Set up steps
    # 8. Add data storage: incus config device add samba storage disk source=/mnt/storage path=/mnt/storage/ raw.mount.options=idmap=b:998:0:1

    # Proxy ports from host to container
    # incus config device add samba tcp_proxy proxy listen=tcp:0.0.0.0:139,445 connect=tcp:10.223.27.82:139,445
    # incus config device add samba udp_proxy proxy listen=udp:0.0.0.0:137,138 connect=udp:10.223.27.82:137,138

    sops.secrets."samba-passwords/bryan" = {
      sopsFile = ./secrets/samba.yaml;
      restartUnits = ["update-samba-passwords.service"];
    };
    sops.secrets."samba-passwords/renee" = {
      sopsFile = ./secrets/samba.yaml;
      restartUnits = ["update-samba-passwords.service"];
    };

    # Add users just for samba authentication
    users.groups.samba = {};
    users.users = {
      bryan = {
        name = "bryan";
        isSystemUser = true;
        group = "samba";
      };
      renee = {
        name = "renee";
        isSystemUser = true;
        group = "samba";
      };
    };

    # Set Samba passwords via shell script
    systemd.services.update-samba-passwords = {
      script = ''
        set -euxo pipefail
        double() {
          ${pkgs.coreutils}/bin/cat $1
          echo
          ${pkgs.coreutils}/bin/cat $1
          echo
        }
        shopt -s nullglob
        for file in /run/secrets/samba-passwords/*; do
          user=$(basename $file)
          double $file | ${pkgs.samba}/bin/smbpasswd -L -a -s $user
          rm -f $file
        done
      '';
      serviceConfig = {
        Type = "oneshot";
      };
    };

    # Set password for samba users manually
    # incus exec samba -- smbpasswd -a bryan

    services.samba = {
      enable = true;
      openFirewall = true;
      settings = {
        global = {
          "server string" = "samba";
          "hosts allow" = ["10.223.27." "192.168.1." "127." "100."];
          "hosts deny" = ["ALL"];
          "bind interfaces only" = "yes";
          "interfaces" = ["lo" "eth0"];
          "server role" = "standalone server";
          "smb encrypt" = "desired";
          "max log size" = 50;
          # disable printer support
          "load printers" = "no";
          printing = "bsd";
          "printcap name" = "/dev/null";
          "disable spoolss" = "yes";
          "show add printer wizard" = "no";
        };
        hyshka = {
          path = "/mnt/storage/hyshka";
          "valid users" = "bryan";
          browseable = "yes";
          "read only" = "no";
          "guest ok" = "no";
          comment = "hyshka home folder";
        };
        tm_share = {
          path = "/mnt/storage/tm_share";
          "valid users" = "renee";
          public = "no";
          writeable = "yes";
          "force user" = "renee";
          # Below are the most imporant for macOS compatibility
          "fruit:aapl" = "yes";
          "fruit:time machine" = "yes";
          "fruit:copyfile" = "yes";
          "vfs objects" = "catia fruit streams_xattr";
        };
      };
    };

    services.samba-wsdd = {
      enable = true;
      # TODO: need to expose this on tiny1 for this to work
      openFirewall = true;
    };

    services.avahi = {
      publish.enable = true;
      publish.userServices = true;
      enable = true;
      # TODO: need to expose this on tiny1 for this to work
      openFirewall = true;
      extraServiceFiles = {
        timemachine = ''
          <?xml version="1.0" standalone='no'?>
          <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
          <service-group>
            <name replace-wildcards="yes">%h</name>
            <service>
              <type>_smb._tcp</type>
              <port>445</port>
            </service>
              <service>
              <type>_device-info._tcp</type>
              <port>0</port>
              <txt-record>model=TimeCapsule8,119</txt-record>
            </service>
            <service>
              <type>_adisk._tcp</type>
              <!--
                change tm_share to share name, if you changed it.
              -->
              <txt-record>dk0=adVN=tm_share,adVF=0x82</txt-record>
              <txt-record>sys=waMa=0,adVF=0x100</txt-record>
            </service>
          </service-group>
        '';
      };
    };
  }
