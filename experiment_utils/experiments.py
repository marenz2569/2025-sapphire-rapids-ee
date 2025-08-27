from datetime import datetime
import glob
import os
from pathlib import Path
from typing import Callable, List, NamedTuple, Self

"""
The environment folder which is used to find the results folder
"""
RESULTS_FOLDER_ENV_VAR = 'TEST_ROOT'

"""
Represents the data associated to all experiments.
A experiment is represented by a folder structure host/experiment_name/time/ relative to a root folder.
"""
class Experiment(NamedTuple):
    host: str
    experiment_name: str
    time: datetime
    path: Path

    """
    Get the folder where the results are saved from the RESULTS_FOLDER environment variable.
    @returns the Path to the folder where results are saved.
    """
    @staticmethod
    def get_results_folder() -> Path:
        if RESULTS_FOLDER_ENV_VAR not in os.environ:
            raise Exception(f'{RESULTS_FOLDER_ENV_VAR} env variable not given.')

        return Path(os.environ[RESULTS_FOLDER_ENV_VAR])

    """
    Parse the experiment data from a given path
    @arg path The path of the experiment data
    """
    @staticmethod
    def from_path(path: Path) -> Self:
        assert len(path) >= 2

        time = datetime(path.name)
        experiment_name = path.parents[0]
        host = path.parents[1]

        return Experiment(host=host, experiment_name=experiment_name, time=time)

    """
    Get the list of experiments from the results folder passed via the environment variable
    @returns The list of experiments
    """
    @staticmethod
    def get_experiments() -> List[Self]:
        root_folder = Experiment.get_results_folder()

        experiment_folders = glob.glob(f'{root_folder.absolute}/*/*/*')
        experiment_folders = list(filter(lambda folder: os.path.isdir(folder), experiment_folders))

        experiments = list(map(Experiment.from_path, experiment_folders))

        return experiments

"""
Class to provide helper functions to filter the list of experiments
"""
class ExperimentFilter:
    """
    Filter the experiments by host name
    @arg host The host which should be filtered
    @returns The filter that filters the list of experiments for the supplied host
    """
    @staticmethod
    def by_host(host: str) -> Callable[[Experiment], bool]:
        def filter(experiment: Experiment):
            return experiment.host == host
        return filter

    """
    Filter the experiments by experiment name
    @arg experiment_name The experiment name which should be filtered
    @returns The filter that filters the list of experiments for the supplied experiment name
    """
    @staticmethod
    def by_experiment_name(experiment_name: str) -> Callable[[Experiment], bool]:
        def filter(experiment: Experiment):
            return experiment.experiment_name == experiment_name
        return filter

    """
    Filter the experiments by time
    @arg time The time which should be filtered
    @returns The filter that filters the list of experiments for the supplied time
    """
    @staticmethod
    def by_time(time: datetime) -> Callable[[Experiment], bool]:
        def filter(experiment: Experiment):
            return experiment.time == time
        return filter
