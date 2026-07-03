{ pkgs, lib, ... }:
{
  PreToolUse = [
    {
      matcher = "Bash";
      hooks = [
        {
          type = "command";
          command = "${lib.getExe pkgs.rtk}/bin/rtk hook claude";
        }
      ];
    }
  ];
}
