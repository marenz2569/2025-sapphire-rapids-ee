# pylint: disable=line-too-long

"""
Provides utilities to set frequencies on intel processors.
"""

import glob
import subprocess


class IntelFrequency:
    """
    Class to provide helper functions to set the frequency on intel processors
    """

    @staticmethod
    def set_core_frequency(frequency_khz: int):
        """
        Set a specific core frequency for all cores on intel processors.
        @arg frequency_khz The frequency of the processor in kHz.
        """
        scaling_min_freq_files = glob.glob('/sys/bus/cpu/devices/cpu*/cpufreq/scaling_min_freq')
        for file in scaling_min_freq_files:
            subprocess.run(['sudo', 'tee', file], input=f'{frequency_khz}', capture_output=True, text=True, check=False)

        scaling_max_freq_files = glob.glob('/sys/bus/cpu/devices/cpu*/cpufreq/scaling_max_freq')
        for file in scaling_max_freq_files:
            subprocess.run(['sudo', 'tee', file], input=f'{frequency_khz}', capture_output=True, text=True, check=False)

    @staticmethod
    def set_uncore_frequency(frequency_in_100mhz: int):
        """
        Set a specific uncore frequency for all sockets on intel processors.
        @arg frequency_in_100mhz The frequency of the processor in 100MHz increments.
        """
        uncore_frequency_string = hex(frequency_in_100mhz << 8 | frequency_in_100mhz)
        subprocess.run(['sudo', 'wrmsr', '-a', '0x620', uncore_frequency_string], capture_output=True, check=True)
