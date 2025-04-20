{
  lib,
  inputs,
  ...
}: let
  container = import ./default.nix {inherit lib inputs;};
in
  container.mkContainer {
    name = "samba";
  }
  // {
    # Set up steps
    # 1. Deploy image to Incus
    # 2. Create container: incus create nixos/custom/samba samba -c security.nesting=true
    # 3. Add persist disk: incus config device add samba persist disk source=/persist/microvms/samba path=/persist shift=true
    # 4. Start container: incus start samba --console
    # 5. Configure static ip: Grab IPv4 from incus list, then incus config device override samba eth0 ipv4.address=10.223.27.X
    # 6. Compute age key: nix-shell -p ssh-to-age --run 'sudo cat /persist/microvms/samba/etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'
    # 7. Update nix-config with static IP and age key, rebuild the image
    # 8. Add data storage: incus config device add samba storage disk source=/mnt/storage path=/mnt/storage/ raw.mount.options=idmap=b:998:0:1

    # Add users
    # sudo smbpasswd -a my_user
    # TODO: declarative users: https://discourse.nixos.org/t/nixos-configuration-for-samba/17079/6
    # https://github.com/dudeofawesome/nix-config/blob/994b57a7b4057d9b63a36614af9e83756a7464d1/modules/configurable/os/samba-users.nix#L77

    services.samba = {
      enable = true;
      openFirewall = true;
      settings = {
        global = {
          "server string" = "samba";
          # restrict access to LAN, localhost
          "hosts allow" = ["10.223.27." "127."];
          # limit connects to LAN and tailnet, lo always required
          "bind interfaces only" = "yes";
          "interfaces" = ["lo" "eth0"];
          # limit log size to 50kb
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
          "valid users" = "hyshka";
          browseable = "yes";
          "read only" = "no";
          "guest ok" = "no";
          comment = "hyshka home folder";
        };
        # TODO: timemachine share
        # https://wiki.nixos.org/wiki/Samba#Apple_Time_Machine
        # https://blog.jhnr.ch/2023/01/09/setup-apple-time-machine-network-drive-with-samba-on-ubuntu-22.04/
        tm_share = {
          path = "/mnt/storage/tm_share";
          "valid users" = "username";
          public = "no";
          writeable = "yes";
          "force user" = "username";
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
      openFirewall = true;
    };

    services.avahi = {
      publish.enable = true;
      publish.userServices = true;
      enable = true;
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
