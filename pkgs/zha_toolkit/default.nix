{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
}:
buildHomeAssistantComponent rec {
  owner = "mdeweerd";
  domain = "zha_toolkit";
  version = "1.1.9";

  src = fetchFromGitHub {
    inherit owner;
    repo = "zha-toolkit";
    rev = "refs/tags/v${version}";
    hash = "sha256-pv1Kp8Qq8s845T7s+Rcsypv39zk8oBuMiLxjUqY8YzI=";
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
