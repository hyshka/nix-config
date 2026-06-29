{
  inputs,
  pkgs,
  lib,
  ...
}:
let
  leanCtxBin = "${
    lib.getBin inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.lean-ctx
  }/bin/lean-ctx";
in
{
  PostToolUse = [
    {
      matcher = ".*";
      hooks = [
        {
          type = "command";
          command = "${leanCtxBin} hook observe";
        }
      ];
    }
  ];
  PreCompact = [
    {
      matcher = ".*";
      hooks = [
        {
          type = "command";
          command = "${leanCtxBin} hook observe";
        }
      ];
    }
  ];
  PreToolUse = [
    {
      matcher = "Bash|bash";
      hooks = [
        {
          type = "command";
          command = "${leanCtxBin} hook rewrite";
        }
      ];
    }
    {
      matcher = "Read|read|ReadFile|read_file|View|view|Grep|grep|Search|search|ListFiles|list_files|ListDirectory|list_directory|Glob|glob";
      hooks = [
        {
          type = "command";
          command = "${leanCtxBin} hook redirect";
        }
      ];
    }
  ];
  SessionEnd = [
    {
      matcher = ".*";
      hooks = [
        {
          type = "command";
          command = "${leanCtxBin} hook observe";
        }
      ];
    }
  ];
  SessionStart = [
    {
      matcher = ".*";
      hooks = [
        {
          type = "command";
          command = "${leanCtxBin} hook observe";
        }
      ];
    }
  ];
  Stop = [
    {
      matcher = ".*";
      hooks = [
        {
          type = "command";
          command = "${leanCtxBin} hook observe";
        }
      ];
    }
  ];
  UserPromptSubmit = [
    {
      matcher = ".*";
      hooks = [
        {
          type = "command";
          command = "${leanCtxBin} hook observe";
        }
      ];
    }
  ];
}
