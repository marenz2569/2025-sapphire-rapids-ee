{
  lib,
  buildPythonPackage,
}:

buildPythonPackage rec {
  pname = "experiment_utils";
  version = "0.0.1";

  src = ./.;

  # do not run tests
  doCheck = false;

  # specific to buildPythonPackage, see its reference
  pyproject = false;
  build-system = [];
}