# pylint: disable=line-too-long, missing-module-docstring, missing-class-docstring, missing-function-docstring

import re
import subprocess
from typing import NamedTuple

class LscpuInformation(NamedTuple):
    num_sockets: int

    @staticmethod
    def parse(lscpu_output: str):
        num_sockets = 1
        for line in lscpu_output.splitlines():
            m = re.match(r"\w+Socket\(s\):\w+(?P<num_sockets>\d+)", line)
            if m:
                num_sockets = m.group('num_sockets')

        return LscpuInformation(num_sockets=num_sockets)

    @staticmethod
    def get_lscpu():
        lscpu = subprocess.check_output(["lscpu"])
        return LscpuInformation.parse(lscpu.decode('utf-8'))
