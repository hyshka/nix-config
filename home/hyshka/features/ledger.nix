{
  #config,
  pkgs,
  ...
}: let
  #inherit (config.home) homeDirectory;
  #ledgerDir = "${homeDirectory}/Documents/ledger";
in {
  home.packages = with pkgs;
  with haskellPackages; [
    # https://hledger.org/
    hledger_1_41
    hledger-ui_1_41
    # https://github.com/apauley/hledger-flow
    # TODO
    #hledger-flow
    # https://github.com/siddhantac/puffin
    puffin
  ];

  # TODO
  #home.sessionVariables."LEDGER_FILE" = "~/finance/2023/2023.journal";
  #home.sessionVariables."LEDGER_FILE" = ledgerDir;
}
