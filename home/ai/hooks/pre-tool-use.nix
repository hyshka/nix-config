{ pkgs, ... }:
{
  PreToolUse = [
    {
      matcher = "Bash";
      hooks = [
        {
          type = "command";
          command = "${pkgs.rtk} hook claude";
        }
      ];
    }
  ];
}
