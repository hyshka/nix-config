{
  lib,
  pkgs,
  fetchFromGitHub,
}:
pkgs.buildHomeAssistantComponent rec {
  owner = "mdeweerd";
  domain = "zha_toolkit";
  version = "1.1.22";

  src = fetchFromGitHub {
    inherit owner;
    repo = "zha-toolkit";
    rev = "refs/tags/v${version}";
    hash = "sha256-MOa3YxKUSmaNQAcMp2HXSi1BjYO2sbVcOCNrrEFUUMY=";
  };

  dontBuild = true;

  propagatedBuildInputs = [];

  # enable when pytest-homeassistant-custom-component is packaged
  doCheck = false;

  # nativeCheckInputs = [
  #   pytest-homeassistant-custom-component
  #   pytestCheckHook
  # ];

  meta = with lib; {
    description = "";
    homepage = "https://github.com/mdeweerd/zha-toolkit/";
    maintainers = with maintainers; [hyshka];
    license = licenses.gpl3Only;
  };
}
