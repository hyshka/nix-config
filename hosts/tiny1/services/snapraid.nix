{
  services.snapraid = {
    enable = true;
    parityFiles = [
      "/mnt/parity1/snapraid.parity"
    ];
    contentFiles = [
      "/var/snapraid.content"
      "/mnt/disk3/.snapraid.content"
    ];
    dataDisks = {
      d3 = "/mnt/disk3/";
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
    # disable touch for better compatibility as a receive-only syncthing node.
    # otherwise, the sub-second timestamps will be marked as a local change and
    # prevent syncs.
    touchBeforeSync = false;
    # sync happens daily at 0100, try not to write to files during this time
    scrub = {
      # scrub entire array about once a month
      plan = 16;
    };
    # TODO healthcheck notification for sync & scrub
  };
}
