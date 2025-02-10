from typing import NamedTuple, List, Self

def strip_to_int(input_list : List[str]) -> List[int]:
    striped_list = list(map(lambda elem: elem.strip(), input_list))
    return list(map(int, striped_list))

def strip_to_float(input_list : List[str]) -> List[float]:
    striped_list = list(map(lambda elem: elem.strip(), input_list))
    return list(map(float, striped_list))

class Experiment(NamedTuple):
    cores: int
    name: str
    description: str
    ovrlp3: float
    mops: List[int]
    aperf_mperf_ratio: List[float]
    aperf_mperf_mhz: List[int]
    mperf_tsc_ratio: List[float]

    @staticmethod
    def parse(line: str) -> Self:
        items = line.split('|')

        items = list(map(lambda elem: elem.strip(), items))

        cores = int(items[0])
        name = items[1]
        description = items[2]
        ovrlp3 = float(items[3])
        mops = strip_to_int(items[4].split(','))
        aperf_mperf_ratio = strip_to_float(items[5].split(','))
        aperf_mperf_mhz = strip_to_int(items[6].split(','))
        mperf_tsc_ratio = strip_to_float(items[7].split(','))

        return Experiment(cores, name, description, ovrlp3, mops, aperf_mperf_ratio, aperf_mperf_mhz, mperf_tsc_ratio)

class AvxTurbo(NamedTuple):
    experiments: List[Experiment]

    @staticmethod
    def parse(file_name: str) -> Self:
        fp = open(file_name, 'r')

        experiments = []

        start_found = False

        for line in fp.readlines():
            # All sections starts with the line "Cores ... | ..."
            # We use this to detect the start of data
            if line.startswith("Cores"):
                start_found = True
                continue

            # Skip empty lines
            if not line.strip():
                continue

            if not start_found:
                continue

            experiments.append(Experiment.parse(line))

        return AvxTurbo(experiments)