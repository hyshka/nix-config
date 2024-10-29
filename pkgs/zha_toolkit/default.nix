{
  lib,
  pkgs,
  fetchFromGitHub,
}:
pkgs.buildHomeAssistantComponent rec {
  owner = "mdeweerd";
  domain = "zha_toolkit";
  version = "1.1.19";

  src = fetchFromGitHub {
    inherit owner;
    repo = "zha-toolkit";
    rev = "refs/tags/v${version}";
    hash = "sha256-cMCGLDngtIFuEiXZiHBUf6ltW9u0LY81un/Igd9Ai6Y=";
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
