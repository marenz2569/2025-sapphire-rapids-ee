{
  lib,
  buildPythonPackage,
  setuptools,
  matplotlib
}:

buildPythonPackage {
  pname = "experiment_utils";
  version = "0.0.1";

  src = ./.;

  # do not run tests
  doCheck = false;

  pythonImportsCheck = [
    "experiment_utils"
  ];

  pyproject = true;
  nativeBuildInputs = [
    setuptools
  ];

  buildInputs = [
    matplotlib
  ];
}