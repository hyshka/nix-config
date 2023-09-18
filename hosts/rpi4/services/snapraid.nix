{
  snapraid = {
    enable = true;
    parityFiles = [
      "/mnt/parity1/snapraid.parity"
    ];
    contentFiles = [
      "/var/snapraid.content"
      "/mnt/disk1/.snapraid.content"
      "/mnt/disk2/.snapraid.content"
    ];
    dataDisks = {
      d1 = "/mnt/disk1/";
      d2 = "/mnt/disk2/";
    };
    exclude = [
      # https://github.com/IronicBadger/infra/blob/master/group_vars/morpheus.yaml#L52
      "*.unrecoverable"
      "/tmp/"
      "/lost+found/"
      "downloads/"
      "appdata/"
      "*.!sync"
      ".AppleDouble"
      "._AppleDouble"
      ".DS_Store"
      "._.DS_Store"
      ".Thumbs.db"
      ".fseventsd"
      ".Spotlight-V100"
      ".TemporaryItems"
      ".Trashes"
      ".Trash-*"
      ".AppleDB"
      ".nfo"
    ];
    #sync.interval = "01:00"; # defaults to daily at 1 am
    scrub = {
      # TODO these PMS values may be out-of-date, snapraid recommends scrub once/week
      #plan = 22; # 22%
      #olderThan = 8;
      # interval = "Mon *-*-* 02:00:00"; # defaults to every Monday at 2 am
    };
    # TODO healthcheck notification for sync & scrub
  };
}
