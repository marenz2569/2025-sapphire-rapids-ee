# Copyright (C) 2021 TU Dresden, Center for Information Services and
# High Performance Computing
# Copyright (C) 2025 Markus Schmidl
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# pylint: disable=line-too-long,missing-module-docstring,too-many-arguments,too-many-positional-arguments

import asyncio
import os
from typing import List, Dict
from uuid import uuid4
import metricq
from metricq.history_client import HistoryRequestType

from .counter import Counter

class BinnedHistoryClient():
    """
    This class provides the functionality to fetch aggregated and binned history metric data for multiple metrics from metricq.
    """

    def __init__(self, token: str, start_timestamp: metricq.Timestamp, stop_timestamp: metricq.Timestamp, metric_binsize: float=0.1, server: str | None=os.environ.get('METRICQ_SERVER')):
        """
        \arg token The token that is used to talk to the server
        \arg start_timestamp The timestamp from which to retrieve data
        \arg stop_timestamp The timestamp until which to retrieve data
        \arg metric_binsize The size of the bins, default 0.1W
        \arg server The server that is used to access metricq
        """
        if server is None:
            raise RuntimeError("Metricq server cannot be None. Check that it is either set with the envrionment variable METRICQ_SERVER passed as an argument.")

        self.server = server
        self.start_timestamp = start_timestamp
        self.stop_timestamp = stop_timestamp
        self.metric_binsize = metric_binsize
        self.token = token

    async def aget_counter(self, metric: str, chunk_size: metricq.Timedelta, maximal_aggregation_interval: metricq.Timedelta) -> Counter:
        """
        Spawn a metricq HistoryClient to retrieve aggregated and binned counts for a specifed metric.
        \arg metric The metric to fetch and bin
        \arg chunk_size The size (timedelta) of a the chunked transfer
        \arg maximal_aggregation_interval The maximum aggregation bin width
        """
        # The counter for the meticq value bins
        metric_bin_counter = Counter()

        client = metricq.HistoryClient(token=f"{self.token}-{uuid4()}", url=self.server)

        await client.connect()

        chunk_begin = self.start_timestamp
        while chunk_begin < self.stop_timestamp:
            chunk_end = chunk_begin + chunk_size
            chunk_end = min(chunk_end, self.stop_timestamp)
            print(f"Requesting chunk from {chunk_begin} to {chunk_end} of {metric}")

            result = await client.history_data_request(
                metric,
                start_time=chunk_begin,
                end_time=chunk_end,
                interval_max=maximal_aggregation_interval,
                request_type=HistoryRequestType.AGGREGATE_TIMELINE,
                timeout=240
            )
            for aggregate in result.aggregates():
                if aggregate.timestamp < chunk_begin:
                    continue
                if aggregate.count == 0:
                    continue
                key = float(int(aggregate.sum / aggregate.count / self.metric_binsize) * self.metric_binsize)
                metric_bin_counter[key] += 1
            chunk_begin = chunk_end

        await client.stop(None)

        return metric_bin_counter

    async def aget_counters(self, metrics: List[str], chunk_size: metricq.Timedelta, maximal_aggregation_interval: metricq.Timedelta):
        """
        Spawn a asyncio tasks to retrieve aggregated and binned counts for a specifed list of metrics.
        \arg metrics The list of metrics to fetch and bin
        \arg chunk_size The size (timedelta) of a the chunked transfer
        \arg maximal_aggregation_interval The maximum aggregation bin width
        \returns List of asyncio tasks for each metric
        """
        counters = []

        for metric in metrics:
            counters.append(await asyncio.create_task(self.aget_counter(metric=metric, chunk_size=chunk_size, maximal_aggregation_interval=maximal_aggregation_interval)))

        return counters

    def get_counters(self, metrics: List[str], chunk_size: metricq.Timedelta, maximal_aggregation_interval: metricq.Timedelta) -> Dict[str, Counter]:
        """
        Retrieve aggregated and binned counts for a specifed list of metrics.
        \arg metrics The list of metrics to fetch and bin
        \arg chunk_size The size (timedelta) of a the chunked transfer
        \arg maximal_aggregation_interval The maximum aggregation bin width
        \returns A dict from metric to retrieved binned metric counts
        """
        counters = asyncio.run(self.aget_counters(metrics=metrics, chunk_size=chunk_size, maximal_aggregation_interval=maximal_aggregation_interval))
        return dict(zip(metrics, counters))
