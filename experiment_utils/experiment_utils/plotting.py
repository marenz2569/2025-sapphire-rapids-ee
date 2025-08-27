import matplotlib.pyplot as plt
import os
from pathlib import Path
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
    Save an figure of an experiment in the thesis/fig folder.
    @arg experiment The experiment for which the plot will be saved.
    @arg file_name The file name of the plot which will be saved into thesis/fig/experiment_name.
    """
    @staticmethod
    def savefig(experiment: Experiment, file_name: str):
        save_dir = Plotting.get_fig_folder() / experiment.experiment_name
        os.makedirs(save_dir, exist_ok=True)
        plt.savefig(save_dir / file_name, bbox_inches='tight')