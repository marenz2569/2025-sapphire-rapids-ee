#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import subprocess
from utils.numactl_parser import NumaNode, NumaNodes
from utils.lscpu_parser import LscpuInformation
from typing import List

def get_all_cpus(nodes: List[NumaNode]) -> List[int]:
    cpus = list()

    for node in nodes:
        for cpu in node.cpu_list:
            cpus.append(cpu)

    return cpus

def disable_smt():
    subprocess.run(['sudo', 'tee', '/sys/devices/system/cpu/smt/control'], input='off', capture_output=True, text=True)

def set_core_frequency(freq_in_khz: int):
    subprocess.run(['sudo', 'tee', '/sys/bus/cpu/devices/cpu*/cpufreq/scaling_min_freq'], input=f'{freq_in_khz}', capture_output=True, text=True)
    subprocess.run(['sudo', 'tee', '/sys/bus/cpu/devices/cpu*/cpufreq/scaling_max_freq'], input=f'{freq_in_khz}', capture_output=True, text=True)

def set_uncore_frequency(frequency_in_100mhz: int):
    uncore_frequency_string = hex(frequency_in_100mhz << 8 | frequency_in_100mhz)
    subprocess.run(['sudo', 'wrmsr', '-a', '0x620', uncore_frequency_string], capture_output=True)

def measure(nodes: NumaNodes):
    all_cpus = get_all_cpus(nodes)

    # We loop over all numa nodes and measure the cache line latencies from
    # all CPUs in this NUMA node to all CPUs.
    # The memory is always allocated in the source node
    for node in nodes.nodes:
        for this_cpu in node.cpu_list:
            for other_cpu in all_cpus:
                # Create the directory for the measurement results

                # This will run around 10 seconds on the same socket
                # Run it in the created directory
                print(f'numactl --membind={node.node_id} ./software/atomic-latencies/atomic-latencies {this_cpu},{other_cpu} 100 1000 64 100')


def main():
    disable_smt()

    nodes = NumaNodes.get_numa_nodes()
    lscpu = LscpuInformation.get_lscpu()
    # core frequencies in kHz
    core_frequencies = [ 800000, 2000000, 3800000 ]
    # uncore frequencies in 100MHz
    uncore_frequencies = [ 8, 25 ]

    for core_frequency in core_frequencies:
        # Set the core frequency fixed
        set_core_frequency(core_frequency)

        for uncore_frequency in uncore_frequencies:
            # Set the uncore frequency fixed
            set_uncore_frequency(uncore_frequency)

            # Only run the measurement on socket 0
            # Assume that each socket has the same number of NUMA nodes
            filtered_nodes = list(filter(lambda node: node.node_id < len(nodes.nodes) // lscpu.num_sockets, nodes.nodes))

            print(f'Running measurement (core frequency: {core_frequency}kHz, uncore frequency: {uncore_frequency}00MHz) on nodes {filtered_nodes}')

            # Measure the cachelines of the node
            measure(filtered_nodes)

if __name__ == "__main__":
    main()
