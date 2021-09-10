# nothing here right now
from concurrent.futures import ThreadPoolExecutor
from datetime import timedelta
from typing import Callable, Iterable


def work(nthreads, fn: Callable, items: Iterable, timeout: timedelta=None):
    jobs = []

    with ThreadPoolExecutor(max_workers=nthreads) as pool:
        # submit each job to the pool, and capture the future to make sure no exceptions were thrown
        for item in items:
            jobs.append(pool.submit(fn, item))
        # check the jobs to see if any exceptions thrown
        for job in jobs:
            exc = job.exception(timeout.total_seconds() if timeout else None)
            if exc is not None:
                if isinstance(exc, SystemExit):
                    exc = ProcessExit("Process exited")
                raise exc


class ProcessExit(Exception):
    pass