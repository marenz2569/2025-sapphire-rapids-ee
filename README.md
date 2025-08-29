# Code support package for "An Analysis of the Intel Sapphire Rapids Architecture's Energy Efficiency Features"

This repository contains all files that are required to build the paper.
It is structed into the following folders:
- `thesis` contains the latex code.
- `measurements` contains all code to execute the measurements and create the plots.
- `experiment_utils` contains a python library that provides utility functions for all jupyter notebooks.

The folder `.github` contains the github actions CI files.
`*.nix` files are required to get obtain a python kernel for creating plots.

# Running Measurements

Create a build folder and compile the code in the `measurements` folder with CMake.
Run the test using CTest.
Make shure to specify the `TEST_ROOT` environment variable to the root of the folder where results are saved.

# Visualizing data manually

To execute the juptyer server run: `nix run .# -- -m jupyter notebook --no-browser`.

Set the `TEST_ROOT` environment variable to the folder where experiment results are saved.
Set the `FIG_ROOT` environment variable to the folder where figure should be saved.
Attach to the server via the provided ports and passwort on the stdout.
This can be achieved by using a port forward: `ssh hati -L 8888:localhost:8888`

## Setting a fixed password for jupyter

Execute `nix run .# -- -m jupyter notebook password` and provide a password when promted.

# Visualizing data automatically

Create the figures via CTest.
Set the environment variables as described in the above section.

# References
This is the code-support package for the following paper.
Please cite the paper if you use parts of this repository for scientific work.

Markus Schmidl: An Analysis of the Intel Sapphire Rapids Architecture's Energy Efficiency Features (2025),
DOI: 

# License

If not specified otherwise, files in this repository are licensed under `MIT`.
