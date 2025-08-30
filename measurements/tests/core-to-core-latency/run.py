#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# pylint: disable=line-too-long, missing-function-docstring, missing-module-docstring

import json
import os
import sys
import subprocess
from typing import List
import glob
from pathlib import Path
import shutil
from utils.numactl_parser import NumaNode, NumaNodes
from utils.lscpu_parser import LscpuInformation

def get_all_cpus(nodes: List[NumaNode]) -> List[int]:
    cpus = []

    for node in nodes:
        for cpu in node.cpu_list:
            cpus.append(cpu)

    return cpus

def disable_smt():
    subprocess.run(['sudo', 'tee', '/sys/devices/system/cpu/smt/control'], input='off', capture_output=True, text=True, check=True)

def set_core_frequency(freq_in_khz: int):
    scaling_min_freq_files = glob.glob('/sys/bus/cpu/devices/cpu*/cpufreq/scaling_min_freq')
    for file in scaling_min_freq_files:
        subprocess.run(['sudo', 'tee', file], input=f'{freq_in_khz}', capture_output=True, text=True, check=False)

    scaling_max_freq_files = glob.glob('/sys/bus/cpu/devices/cpu*/cpufreq/scaling_max_freq')
    for file in scaling_max_freq_files:
        subprocess.run(['sudo', 'tee', file], input=f'{freq_in_khz}', capture_output=True, text=True, check=False)

def set_uncore_frequency(frequency_in_100mhz: int):
    uncore_frequency_string = hex(frequency_in_100mhz << 8 | frequency_in_100mhz)
    subprocess.run(['sudo', 'wrmsr', '-a', '0x620', uncore_frequency_string], capture_output=True, check=True)

def measure(nodes: List[NumaNode], settings: dict, results_folder: Path):
    all_cpus = get_all_cpus(nodes)

    if 'ATOMIC_LATENCIES' not in os.environ:
        print('ATOMIC_LATENCIES env variable is not set')
        sys.exit(1)

    atomic_latencies = os.environ['ATOMIC_LATENCIES']

    # We loop over all numa nodes and measure the cache line latencies from
    # all CPUs in this NUMA node to all CPUs.
    # The memory is always allocated in the source node
    for node in nodes:
        for this_cpu in node.cpu_list:
            for other_cpu in all_cpus:
                # Skip the self edge
                if this_cpu == other_cpu:
                    continue

                # For two cpus in the same NUMA node, we do not need to measure twice
                if other_cpu in node.cpu_list and this_cpu > other_cpu:
                    continue

                # Create the directory for the measurement results
                outfolder = results_folder / f'{this_cpu}' / f'{other_cpu}'
                os.makedirs(outfolder)

                settings['memory_in_numa_node'] = node.node_id
                settings['this_cpu'] = this_cpu
                settings['other_cpu'] = other_cpu

                # This will run around 10 seconds on the same socket
                subprocess.run(
                    ['numactl',
                     f'--membind={node.node_id}',
                     atomic_latencies,
                     # do a ping pong between the cores this_cpu and other_cpu
                     f'{this_cpu},{other_cpu}',
                     # repeat each pingpong for 100 times
                     '100',
                     # use 1000 caches lines
                     '1000',
                     # each with a size of 64B
                     '64',
                     # repeat the measurement for 100 times
                     '100'],
                    # Run it in the created directory. This will save flush_results.txt and latency_results.txt
                    cwd=outfolder,
                    capture_output=True,
                    text=True,
                    check=True)

                with open(Path(outfolder / 'settings.json'), 'w', encoding='utf-8') as f:
                    json.dump(settings, f)

                # Duplicate the entries if we are in the same NUMA node
                if other_cpu in node.cpu_list:
                    settings['this_cpu'] = other_cpu
                    settings['other_cpu'] = this_cpu

                    copied_outfolder = results_folder / f'{other_cpu}' / f'{this_cpu}'
                    os.makedirs(copied_outfolder)

                    # Copy the results folder content
                    shutil.copy(Path(outfolder / 'flush_results.txt'), copied_outfolder)
                    shutil.copy(Path(outfolder / 'latency_results.txt'), copied_outfolder)
                    with open(Path(copied_outfolder / 'settings.json'), 'w', encoding='utf-8') as f:
                        json.dump(settings, f)

def main():
    if 'RESULTS_FOLDER' not in os.environ:
        print('RESULTS_FOLDER env variable is not set')
        sys.exit(1)
    results_foler = Path(os.environ['RESULTS_FOLDER'])

    disable_smt()

    nodes = NumaNodes.get_numa_nodes()
    lscpu = LscpuInformation.get_lscpu()
    # core frequencies in kHz
    core_frequencies = [ 800000, 2000000, 3800000 ]
    # uncore frequencies in 100MHz
    uncore_frequencies = [ 8, 25 ]

    # The settings of the current measurement
    settings = {}

    for core_frequency in core_frequencies:
        # Set the core frequency fixed
        set_core_frequency(core_frequency)
        settings['core_frequency'] = core_frequency

        # Folder for the measurements
        core_folder = results_foler / f'{core_frequency}'

        for uncore_frequency in uncore_frequencies:
            # Set the uncore frequency fixed
            set_uncore_frequency(uncore_frequency)
            settings['uncore_frequency'] = uncore_frequency

            # Create folder for the measurements
            uncore_folder = core_folder / f'{uncore_frequency}'
            os.makedirs(uncore_folder)

            # Only run the measurement on socket 0
            # Assume that each socket has the same number of NUMA nodes
            filtered_nodes = list(filter(lambda node: node.node_id < (len(nodes.nodes) // lscpu.num_sockets), nodes.nodes))

            print(f'Running measurement (core frequency: {core_frequency}kHz, uncore frequency: {uncore_frequency}00MHz) on nodes {filtered_nodes}')

            # Measure the cachelines of the node
            measure(filtered_nodes, settings, uncore_folder)

if __name__ == "__main__":
    main()
