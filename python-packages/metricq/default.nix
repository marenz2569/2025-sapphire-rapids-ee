{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  mypy-protobuf,
  click,
  click-log,
  python-dotenv,
  pandas,
  deprecated,
  python-dateutil,
  aio-pika,
  yarl
}:
buildPythonPackage rec {
  pname = "metricq";
  version = "5.4.0";
  src = fetchFromGitHub {
    owner = pname;
    repo = "${pname}-python";
    rev = "v${version}";
    sha256 = "sha256-wsUFVXNOfiPVGgzutgD+JfmFkr/BcLb+IulXBlI5Q34=";
    fetchSubmodules = true;
  };

  patches = [
    ./add_protobuf_major_6.patch
  ];

  doCheck = true;
  pythonImportsCheck = [
    "metricq"
    "metricq.cli"
    "metricq.pandas"
    "metricq.timeseries"
    # packaged in lib/metricq-protobuf
    # "metricq_proto"
  ];
  pyproject = true;
  nativeBuildInputs = [
    setuptools
    mypy-protobuf
  ];
  pythonPath = [
  ];
  buildInputs = [
    mypy-protobuf
    click
    click-log
    python-dotenv
    pandas
    deprecated
    python-dateutil
    aio-pika
    yarl
  ];
}