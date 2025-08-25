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

        pythonEnv = pkgs.python3.withPackages (ps: with ps; [
          ipykernel
          ipython
          jupyter
          matplotlib
          numpy
          pandas
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