# pylint: disable=line-too-long

"""
Utilities for plotting experiment data
"""

import os
from pathlib import Path
import subprocess
from typing import List
import matplotlib.pyplot as plt
from .experiments import Experiment

# The environment folder which is used to find the results folder
FIG_FOLDER_ENV_VAR = 'FIG_ROOT'

class Plotting:
    """
    Function to aid in saving plots
    """

    @staticmethod
    def get_fig_folder() -> Path:
        """
        Get the folder where the results are saved from the FIG_ROOT environment variable.
        @return The path to the folder where the figs are saved
        """
        if FIG_FOLDER_ENV_VAR not in os.environ:
            raise RuntimeError(f'{FIG_FOLDER_ENV_VAR} env variable not given.')

        return Path(os.environ[FIG_FOLDER_ENV_VAR])

    @staticmethod
    def get_gitrev() -> str:
        """
        Get the cuurent git revision
        @returns The current git revision
        """
        result = subprocess.run(['git', 'describe', '--always', '--abbrev=40', '--dirty'],
                                cwd=Plotting.get_fig_folder(),
                                capture_output=True,
                                text=True,
                                check=True)

        return result.stdout.strip()

    @staticmethod
    def create_save_dir(experiment_name: str) -> Path:
        """
        Create a folder for the experiment figures to be saved.
        @arg experiment The experiment for which data will be saved.
        @returns The folder where the experiment data should be saved.
        """
        save_dir = Plotting.get_fig_folder() / experiment_name
        os.makedirs(save_dir, exist_ok=True)

        return save_dir

    @staticmethod
    def savefig(experiments: Experiment | List[Experiment], file_name: str, annotations_y_offset: float=0.1, annotations_y_spacing: float=0.0125, annotations_x_offset: float=0.01):
        """
        Save an figure of an experiment in the thesis/fig folder.
        @arg experiment The experiment or list of experiments for which the plot will be saved.
        @arg file_name The file name of the plot which will be saved into thesis/fig/experiment_name.
        @arg annotations_y_offset The y offset of the git revision annotations.
        @arg annotations_y_spacing The y spacing between thethe git revision annotations.
        @arg annotations_x_offset The x offset of the git revision annotations.
        """
        experiment_name: str = ""
        num_experiments: int = 1
        list_experiments: List[Experiment] = []

        if isinstance(experiments, list):
            names = list(set(map(lambda experiment: experiment.experiment_name, experiments)))
            if len(names) > 1:
                raise RuntimeError("List of experiments contains more that one experiment name")
            experiment_name = names[0]
            num_experiments = len(experiments)
            list_experiments = experiments
        elif isinstance(experiments, Experiment):
            experiment_name = experiments.experiment_name
            # convert to list
            list_experiments = [ experiments ]
        else:
            raise RuntimeError("Type mismatch on experiments")

        save_dir = Plotting.create_save_dir(experiment_name=experiment_name)

        for i, experiment in enumerate(list_experiments):
            plt.figtext(annotations_x_offset,
                        annotations_y_offset - i * annotations_y_spacing,
                        f'Data created on {experiment.host} with git revision {experiment.get_gitrev().strip()} at {experiment.time}',
                        fontsize=6,
                        va="top",
                        ha="left",
                        color='gray')

        plt.figtext(annotations_x_offset,
                    annotations_y_offset - num_experiments * annotations_y_spacing,
                    f'Plot created with git revision {Plotting.get_gitrev()}',
                    fontsize=6,
                    va="top",
                    ha="left",
                    color='gray')

        plt.savefig(save_dir / file_name, bbox_inches='tight')
