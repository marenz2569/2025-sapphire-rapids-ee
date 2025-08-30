{
  lib,
  buildPythonPackage,
  setuptools,
  matplotlib,
  numpy,
  pandas
}:

buildPythonPackage {
  pname = "experiment_utils";
  version = "0.0.1";

  src = ./.;

  # do not run tests
  doCheck = false;

  pythonImportsCheck = [
    "experiment_utils"
    "experiment_utils.roco2_python"
  ];

  pyproject = true;
  nativeBuildInputs = [
    setuptools
  ];

  buildInputs = [
    matplotlib
    numpy
    pandas
  ];
}