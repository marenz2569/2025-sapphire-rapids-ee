#!/bin/sh

# "Energy Efficiency Features of the Intel Alder Lake Architecture" Artifact Collection
# Copyright (C) 2024 TU Dresden, Center for Information Services and High Performance Computing
#
# This file is part of the "Energy Efficiency Features of the Intel Alder Lake Architecture" Artifact Collection.
#
# The "Energy Efficiency Features of the Intel Alder Lake Architecture" Artifact Collection is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
#
# The "Energy Efficiency Features of the Intel Alder Lake Architecture" Artifact Collection is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with "Energy Efficiency Features of the Intel Alder Lake Architecture" Artifact Collection. If not, see <https://www.gnu.org/licenses/>.


DEFAULT_MSR=`rdmsr 0x620`

gcc latency_test.c -DNOAUTO -DDEFAULT_RANGE=0x$DEFAULT_MSR -o latency_test_specific
gcc latency_test.c -DDEFAULT_RANGE=0x$DEFAULT_MSR -o latency_test_all

echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

./latency_test_all > result.log

echo userspace | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

echo 3200000 | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_setspeed

./latency_test_specific > result_only_set_3200.log

echo 800000 | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_setspeed

./latency_test_specific > result_only_set_800.log

