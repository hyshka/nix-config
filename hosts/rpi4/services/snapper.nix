{
  services.snapper = {
      configs = {
              storage = {
                  # TODO should this go through mergerfs?
                  SUBVOLUME = "/mnt/disk1/hyshka";
        	  TIMELINE_CREATE = true;
        	  TIMELINE_CLEANUP = true;
                  TIMELINE_LIMIT_HOURLY = 12;
                  TIMELINE_LIMIT_DAILY = 7;
                  TIMELINE_LIMIT_WEEKLY = 4;
                  TIMELINE_LIMIT_MONTHLY = 3;
                  TIMELINE_LIMIT_YEARLY = 0;
                };
      };
  };
}
