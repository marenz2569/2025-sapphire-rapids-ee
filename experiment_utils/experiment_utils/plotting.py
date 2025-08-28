import matplotlib.pyplot as plt
import os
from pathlib import Path
import subprocess
from .experiments import Experiment

"""
The environment folder which is used to find the results folder
"""
FIG_FOLDER_ENV_VAR = 'FIG_ROOT'

"""
Function to aid in saving plots
"""
class Plotting:
    """
    Get the folder where the results are saved from the FIG_ROOT environment variable.
    @return The path to the folder where the figs are saved
    """
    @staticmethod
    def get_fig_folder() -> Path:
        if FIG_FOLDER_ENV_VAR not in os.environ:
            raise Exception(f'{FIG_FOLDER_ENV_VAR} env variable not given.')

        return Path(os.environ[FIG_FOLDER_ENV_VAR])

    """
    Get the cuurent git revision
    @returns The current git revision
    """
    @staticmethod
    def get_gitrev() -> str:
        result = subprocess.run(['git', 'describe', '--always', '--abbrev=40', '--dirty'],
                                cwd=Plotting.get_fig_folder(),
                                capture_output=True,
                                text=True)

        return result.stdout.strip()

    """
    Create a folder for the experiment figures to be saved.
    @arg experiment The experiment for which data will be saved.
    @returns The folder where the experiment data should be saved.
    """
    @staticmethod
    def create_save_dir(experiment: Experiment) -> Path:
        save_dir = Plotting.get_fig_folder() / experiment.experiment_name
        os.makedirs(save_dir, exist_ok=True)

        return save_dir

    """
    Save an figure of an experiment in the thesis/fig folder.
    @arg experiment The experiment for which the plot will be saved.
    @arg file_name The file name of the plot which will be saved into thesis/fig/experiment_name.
    @arg annotations_y_offset The y offset of the git revision annotations.
    @arg annotations_y_spacing The y spacing between thethe git revision annotations.
    @arg annotations_x_offset The x offset of the git revision annotations.
    """
    @staticmethod
    def savefig(experiment: Experiment, file_name: str, annotations_y_offset: float=0.1, annotations_y_spacing: float=0.0125, annotations_x_offset: float=0.01):
        save_dir = Plotting.create_save_dir(experiment)

        plt.figtext(annotations_x_offset,
                    annotations_y_offset,
                    f'Data created on {experiment.host} with git revision {experiment.get_gitrev().strip()} at {experiment.time}',
                    fontsize=6,
                    va="top",
                    ha="left")

        plt.figtext(annotations_x_offset,
                    annotations_y_offset - annotations_y_spacing,
                    f'Plot created with git revision {Plotting.get_gitrev()}',
                    fontsize=6,
                    va="top",
                    ha="left")

        plt.savefig(save_dir / file_name, bbox_inches='tight')