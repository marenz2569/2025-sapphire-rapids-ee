"""
Provides utilities for handling experiment data.
"""

from datetime import datetime
import glob
import os
from pathlib import Path
from typing import Callable, List, NamedTuple

# The environment folder which is used to find the results folder
RESULTS_FOLDER_ENV_VAR = 'TEST_ROOT'

class Experiment(NamedTuple):
    """
    Represents the data associated to all experiments.
    A experiment is represented by a folder structure 'host/experiment_name/time/'
    relative to a root folder.
    """

    host: str
    experiment_name: str
    time: datetime
    path: Path

    @staticmethod
    def get_results_folder() -> Path:
        """
        Get the folder where the results are saved from the RESULTS_FOLDER environment variable.
        @returns the Path to the folder where results are saved.
        """
        if RESULTS_FOLDER_ENV_VAR not in os.environ:
            raise RuntimeError(f'{RESULTS_FOLDER_ENV_VAR} env variable not given.')

        return Path(os.environ[RESULTS_FOLDER_ENV_VAR])

    @staticmethod
    def from_path(path: Path) -> 'Experiment':
        """
        Parse the experiment data from a given path
        @arg path The path of the experiment data
        """
        assert len(path.parents) >= 2

        time = datetime.fromisoformat(path.name)
        experiment_name = path.parents[0].name
        host = path.parents[1].name

        return Experiment(host=host, experiment_name=experiment_name, time=time, path=path)

    @staticmethod
    def get_experiments() -> List['Experiment']:
        """
        Get the list of experiments from the results folder passed via the environment variable
        @returns The list of experiments
        """
        root_folder = Experiment.get_results_folder()

        experiment_folders_string = glob.glob(f'{root_folder.absolute()}/*/*/*')
        experiment_folders_string = list(filter(os.path.isdir, experiment_folders_string))
        experiment_folders_paths = list(map(Path, experiment_folders_string))

        experiments = list(map(Experiment.from_path, experiment_folders_paths))

        return experiments

    def get_gitrev(self):
        """
        Get the git revision of the experiment
        @returns The git revision of the experiment
        """
        with open(self.path / 'git-tag', encoding="utf-8")as f:
            return f.read().strip()


class ExperimentFilter:
    """
    Class to provide helper functions to filter the list of experiments
    """

    @staticmethod
    def by_host(host: str) -> Callable[[Experiment], bool]:
        """
        Filter the experiments by host name
        @arg host The host which should be filtered
        @returns The filter that filters the list of experiments for the supplied host
        """
        def filter_experiment(experiment: Experiment):
            return experiment.host == host
        return filter_experiment

    @staticmethod
    def by_experiment_name(experiment_name: str) -> Callable[[Experiment], bool]:
        """
        Filter the experiments by experiment name
        @arg experiment_name The experiment name which should be filtered
        @returns The filter that filters the list of experiments for the supplied experiment name
        """
        def filter_experiment(experiment: Experiment):
            return experiment.experiment_name == experiment_name
        return filter_experiment

    @staticmethod
    def by_time(time: datetime) -> Callable[[Experiment], bool]:
        """
        Filter the experiments by time
        @arg time The time which should be filtered
        @returns The filter that filters the list of experiments for the supplied time
        """
        def filter_experiment(experiment: Experiment):
            return experiment.time == time
        return filter_experiment

    @staticmethod
    def get_latest(experiments: List[Experiment]) -> Experiment:
        """
        Get the latest experiment of a list of experiments
        @arg experiments The list of experiments
        @return The latest experiment execution
        """
        assert len(experiments) > 0

        experiments.sort(key=lambda experiment: experiment.time, reverse=True)

        return experiments[0]
