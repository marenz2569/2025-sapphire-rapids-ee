# pylint: disable=line-too-long, missing-module-docstring, missing-class-docstring, missing-function-docstring

from typing import NamedTuple, List

def number_of_indents(line: str) -> int:
    """
    Return the number of spaces the line starts with
    """
    return len(line) - len(line.lstrip())

class TurboRatioLevel(NamedTuple):
    level: str
    core_count: int
    max_turbo_frequency_mhz: int

    @staticmethod
    def parse(level: str, lines: List[str]) -> List['TurboRatioLevel']:
        level_parsed = level.split('-')[-1]

        turbo_ratio_levels = []

        current_max_cores = 0
        last_max_cores = 0

        for line in lines:
            num_indets = number_of_indents(line)

            # found new entry
            if num_indets == 10:
                last_max_cores = current_max_cores
            else:
                if line.lstrip().startswith('core-count'):
                    current_max_cores = int(line.split(':')[-1])
                else:
                    max_freq = int(line.split(':')[-1])
                    for core_count in range(last_max_cores + 1, current_max_cores + 1):
                        turbo_ratio_levels.append(TurboRatioLevel(level_parsed, core_count, max_freq))

        return turbo_ratio_levels

class Profile(NamedTuple):
    package: int
    die: int
    cpu: int
    level: int

    turbo_levels: List[TurboRatioLevel]

    @staticmethod
    def parse(package: str, die: str, cpu: str, profile: str, lines: List[str]) -> 'Profile':
        package_int = int(package.split('-')[-1])
        die_int = int(die.split('-')[-1])
        cpu_int = int(cpu.split('-')[-1])
        profile_int = int(profile.split('-')[-1])

        turbo_levels = []
        level = ''
        unparsed_trl_lines = []

        for line in lines:
            num_indets = number_of_indents(line)

            if num_indets == 8:
                if line.lstrip().startswith('turbo-ratio-limits'):
                    if len(unparsed_trl_lines) > 0:
                        turbo_levels += TurboRatioLevel.parse(level, unparsed_trl_lines)
                    level = line.strip()
                    unparsed_trl_lines = []
                else:
                    if len(unparsed_trl_lines) > 0:
                        turbo_levels += TurboRatioLevel.parse(level, unparsed_trl_lines)
            else:
                unparsed_trl_lines.append(line)

        return Profile(package_int, die_int, cpu_int, profile_int, turbo_levels)

class IsstPerfProfile(NamedTuple):
    profiles: List[Profile]

    @staticmethod
    def parse(file_name: str) -> 'IsstPerfProfile':
        # pylint: disable=consider-using-with, unspecified-encoding
        fp = open(file_name, 'r')

        profiles = []

        package = ''
        die = ''
        cpu = ''
        profile = ''
        unparsed_profile_lines = []

        for line in fp.readlines():
            num_indets = number_of_indents(line)

            # Empty lines and everything without indents gets discarded
            if not line.strip() or num_indets == 0:
                continue

            if num_indets == 1:
                package = line.strip()
            elif num_indets == 2:
                die = line.strip()
            elif num_indets == 4:
                cpu = line.strip()
            elif num_indets == 6:
                if len(unparsed_profile_lines) > 0:
                    profiles.append(Profile.parse(package, die, cpu, profile, unparsed_profile_lines))
                profile = line.strip()
                unparsed_profile_lines = []
            else:
                unparsed_profile_lines.append(line)

        if len(unparsed_profile_lines) > 0:
            profiles.append(Profile.parse(package, die, cpu, profile, unparsed_profile_lines))

        return IsstPerfProfile(profiles)
