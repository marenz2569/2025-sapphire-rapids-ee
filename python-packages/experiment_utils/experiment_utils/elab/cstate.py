# pylint: disable=line-too-long, missing-function-docstring

"""
Reimpementation of the elab programm utilties.
The code is completly rewriten has has no overlap with the original implementation.
"""

from typing import Optional
import click
from experiment_utils.cstate import Cstate, CstateEnableDisableEnum

@click.group()
def cli():
    pass

def enable(cstate_name: Optional[str], only: bool):
    # Disable all cstates first before only enabling a specific one
    if only:
        Cstate.disable_all()

    if cstate_name is None:
        Cstate.enable_all()
    else:
        Cstate.write_to_cstate(CstateEnableDisableEnum.ENABLE, Cstate.name_to_level(cstate_name))

def disable(cstate_name: Optional[str], only: bool):
    # Enable all cstates first before only enabling a specific one
    if only:
        Cstate.enable_all()

    if cstate_name is None:
        Cstate.disable_all()
    else:
        Cstate.write_to_cstate(CstateEnableDisableEnum.DISABLE, Cstate.name_to_level(cstate_name))

@cli.command(help="Enable or disable cstates")
@click.argument('subcommand', type=click.Choice(['enable', 'disable']), required=True)
@click.argument('cstate_name', required=False)
@click.option('--only', help='Only disable/enable this specific cstate.', is_flag=True)
def cstate(subcommand: str, cstate_name: Optional[str], only: bool):
    if subcommand == 'enable':
        enable(cstate_name=cstate_name, only=only)
    elif subcommand == 'disable':
        disable(cstate_name=cstate_name, only=only)
    else:
        raise RuntimeError('Unreachable codepath')
