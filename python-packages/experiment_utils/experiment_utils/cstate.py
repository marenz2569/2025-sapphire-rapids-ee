# pylint: disable=line-too-long

"""
Provides utilities to enable and disable specific cstates.
"""

from enum import IntEnum
import glob
import subprocess
from typing import List
from pathlib import Path

class CstateEnableDisableEnum(IntEnum):
    """
    Represenation of an enabled or disabled cstate
    """
    ENABLE = 0
    DISABLE = 1


class Cstate:
    """
    Class to provide helper functions to enable and disable specific cstates.
    """

    @staticmethod
    def write_to_cstate(state: CstateEnableDisableEnum, level: int):
        """
        Write either enable or disable to a specific cstate level.
        @arg state Enum that specifies if the state should be enabled or disabled
        @arg level The cstate level that should be manipulated
        """
        cstate_files = glob.glob(f'/sys/devices/system/cpu/cpu*/cpuidle/state{level}/disable')
        for file in cstate_files:
            subprocess.run(['sudo', 'tee', file], input=str(int(state)), capture_output=True, text=True, check=False)

    @staticmethod
    def get_all_state_names() -> List[str]:
        """
        Get the names of all cstates
        @reutrs The list of cstate names
        """
        cstate_levels = glob.glob('/sys/devices/system/cpu/cpu0/cpuidle/state*/name')
        state_names: List[str] = []

        for file in cstate_levels:
            with open(file, 'r', encoding='utf-8') as f:
                state_names.append(f.read().strip())

        return state_names

    @staticmethod
    def name_to_level(cstate: str) -> int:
        """
        Get the state integer for a given cstate name.
        The integer is the number of the 'state*' folder in the cpuidle sysfs entry.
        @return The state integer
        """
        cstate_levels = glob.glob('/sys/devices/system/cpu/cpu0/cpuidle/state*/name')

        for file in cstate_levels:
            with open(file, 'r', encoding='utf-8') as f:
                if f.read().strip() == cstate:
                    state_name = Path(file).parents[0]
                    return int(state_name.name.lstrip('state'))

        raise RuntimeError(f"The specifed cstate {cstate} is not available on this processor.")


    @staticmethod
    def disable_all():
        """
        Disable all cstates
        """
        for state_name in Cstate.get_all_state_names():
            Cstate.write_to_cstate(CstateEnableDisableEnum.DISABLE, Cstate.name_to_level(state_name))

    @staticmethod
    def enable_all():
        """
        Enable all cstates
        """
        for state_name in Cstate.get_all_state_names():
            Cstate.write_to_cstate(CstateEnableDisableEnum.ENABLE, Cstate.name_to_level(state_name))
