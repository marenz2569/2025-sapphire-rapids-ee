from matplotlib.pyplot import plt
import os
from pathlib import Path
from .experiments import Experiment

"""
Function to aid in saving plots
"""
class Plotting:
    """
    Get the path of the thesis/fig folder.
    """
    @staticmethod
    def get_fig_folder() -> Path:
        return Path(__file__).parent / '..' / '..' / 'thesis' / 'fig'

    """
    Save an figure of an experiment in the thesis/fig folder.
    @arg experiment The experiment for which the plot will be saved.
    @arg file_name The file name of the plot which will be saved into thesis/fig/experiment_name.
    """
    @staticmethod
    def savefig(experiment: Experiment, file_name: str):
        save_dir = Plotting.get_fig_folder() / experiment.experiment_name
        os.makedirs(save_dir)
        plt.savefig(save_dir / file_name, bbox_inches='tight')