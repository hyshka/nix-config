{ pkgs, lib, ... }:
let
  tokensaveBin = lib.getExe pkgs.tokensave;
in
{
  PreToolUse = [
    {
      matcher = "Agent|Grep|Bash";
      hooks = [
        {
          type = "command";
          command = tokensaveBin;
          args = [ "hook-pre-tool-use" ];
        }
      ];
    }
  ];
  UserPromptSubmit = [
    {
      hooks = [
        {
          type = "command";
          command = tokensaveBin;
          args = [ "hook-prompt-submit" ];
        }
      ];
    }
  ];
  Stop = [
    {
      hooks = [
        {
          type = "command";
          command = tokensaveBin;
          args = [ "hook-stop" ];
        }
      ];
    }
  ];
}
