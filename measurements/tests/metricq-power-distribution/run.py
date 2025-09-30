#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# pylint: disable=line-too-long, missing-function-docstring, missing-module-docstring

import pickle
from pathlib import Path
import sys
from metricq import Timestamp, Timedelta
from datetime import timedelta
from experiment_utils.metricq import BinnedHistoryClient

def main():
    if 'RESULTS_FOLDER' not in os.environ:
        print('RESULTS_FOLDER env variable is not set')
        sys.exit(1)

    results_foler = Path(os.environ['RESULTS_FOLDER'])

    start_timestamp = Timestamp.from_iso8601("2024-01-01T00:00:00.0Z")
    stop_timestamp = Timestamp.from_iso8601("2025-01-01T00:00:00.0Z")
    chunk_size = Timedelta.from_timedelta(timedelta(days=7))
    maximal_aggregation_interval = Timedelta.from_timedelta(timedelta(seconds=60))

    metrics = [ "barnard.n1001.power" ]

    client = BinnedHistoryClient(token="2025-sapphire-rapids-ee", start_timestamp=start_timestamp, stop_timestamp=stop_timestamp, metric_binsize=0.1)
    counters = client.get_counters(metrics=metrics, chunk_size=chunk_size, maximal_aggregation_interval=maximal_aggregation_interval)

    with open(results_folder / 'counters.pickle', 'wb') as f:
        pickle.dump(counters, f)


if __name__ == "__main__":
    main()
