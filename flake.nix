{
  description = "Jupter with custom python";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

  outputs = {
    self,
    flake-utils,
    nixpkgs,
    ...
  } @ inputs:
    flake-utils.lib.eachSystem
    [
      flake-utils.lib.system.x86_64-linux
    ]
    (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };

        python = pkgs.python3.override {
          self = pkgs.python3;
          packageOverrides = pyfinal: pyprev: {
            experiment_utils = pyfinal.callPackage ./experiment_utils { };
          };
        };

        pythonEnv = python.withPackages (ps: with ps; [
          experiment_utils
          ipykernel
          ipython
          jupyter
          matplotlib
          mypy
          numpy
          pandas
          pylint
          scipy
          seaborn
        ]);
      in rec {
        packages.default = pythonEnv;
        apps.jupyter = {
          program = "${pythonEnv}/bin/jupyter";
          type = "app";
        };
      }
    );
}