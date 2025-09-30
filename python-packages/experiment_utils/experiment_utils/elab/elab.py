# pylint: disable=line-too-long, missing-function-docstring

"""
Reimpementation of the elab utilties.
The code is completly rewriten and has no overlap with the original implementation.
"""

import click
from experiment_utils.elab.cstate import cli as cstate_cli
from experiment_utils.elab.frequency import cli as frequency_cli

def main():
    cli = click.CommandCollection(sources=[cstate_cli, frequency_cli])
    cli()

if __name__ == "__main__":
    main()
