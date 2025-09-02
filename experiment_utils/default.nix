{
  lib,
  buildPythonPackage,
  setuptools,
  click,
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
    "experiment_utils.elab"
    "experiment_utils.roco2_python"
  ];

  pyproject = true;
  nativeBuildInputs = [
    setuptools
  ];

  # https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/python.section.md#buildpythonpackage-function
  # Click is required for the runtime of the elab utility
  pythonPath = [
    click
  ];

  buildInputs = [
    click
    matplotlib
    numpy
    pandas
  ];
}