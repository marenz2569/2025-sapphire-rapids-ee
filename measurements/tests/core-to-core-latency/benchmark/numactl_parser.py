# pylint: disable=line-too-long, missing-module-docstring, missing-class-docstring, missing-function-docstring

import re
import subprocess
from typing import NamedTuple, List

class NumaNode(NamedTuple):
    node_id: int
    cpu_list: List[int]

    @staticmethod
    def parse(node_id, cpu_list: str):
        cpu_list_int = list(map(int, cpu_list.split()))
        return NumaNode(node_id=node_id, cpu_list=cpu_list_int)

class NumaNodes(NamedTuple):
    nodes: List[NumaNode]

    @staticmethod
    def parse(numactl_output: str):
        nodes = []
        for line in numactl_output.splitlines():
            m = re.match(r"node (?P<node_id>\d+) cpus: (?P<cpu_list>\w+)", line)
            if not m:
                continue

            nodes.append(NumaNode.parse(node_id=m.group('node_id'), cpu_list=m.group('cpu_list')))

        return NumaNodes(nodes=nodes)

    @staticmethod
    def get_numa_nodes():
        numactl = subprocess.check_output(["numactl", "-H"])
        return NumaNodes.parse(numactl.stdout)
