# pylint: disable=line-too-long, missing-function-docstring

"""
Reimpementation of the elab programm utilties.
The code is completly rewriten has has no overlap with the original implementation.
"""

import click
from experiment_utils.intel_frequency import IntelFrequency

@click.group()
def cli():
    pass

@cli.command(help="Set the frequency of all cores to a given value in MHz.")
@click.argument('frequency_arg')
def frequency(frequency_arg: str):
    try:
        frequency_khz = int(frequency_arg) * 1000
        IntelFrequency.set_core_frequency(frequency_khz=frequency_khz)
    except ValueError as exc:
        if frequency_arg == "performance":
            IntelFrequency.set_min_core_frequency(frequency_khz=800000)
            IntelFrequency.set_max_core_frequency(frequency_khz=3800000)
        else:
            raise RuntimeError(f"Our experiments are running with the performance governor per default. We do not support settings the specific governor {frequency_arg}.") from exc
