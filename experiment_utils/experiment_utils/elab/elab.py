"""
Reimpementation of the elab programm utilties.
The code is completly rewriten has has no overlap with the original implementation.
"""

import click
from experiment_utils import IntelFrequency

@click.group()
def cli():
    pass

@cli.command(help="Set the frequency of all cores to a given value in kHz.")
@click.argument('frequency')
def frequency(frequency):
    try:
        frequency_khz = int(frequency)
        IntelFrequency.set_core_frequency(frequency_khz=frequency_khz)
    except:
        if frequency != "performance":
            raise RuntimeError("Our experiments are running with the performance governor per default. We do not support settings the specific governor.")

if __name__ == "__main__":
    cli()