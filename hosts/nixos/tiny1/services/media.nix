{
  users.groups.mediacenter = {
    gid = 13000;
  };

  systemd.tmpfiles.rules = [
    "d /mnt/storage/mediacenter/media 2775 1000 13000 - -"
    "d /mnt/storage/mediacenter/media/books 2775 1000 13000 - -"
    "d /mnt/storage/mediacenter/media/audiobooks 2775 1000 13000 - -"
    "d /mnt/storage/mediacenter/downloads 2775 1000 13000 - -"
  ];
}
