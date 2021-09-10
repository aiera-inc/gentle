import multiprocessing
from datetime import timedelta
from multiprocessing.pool import ThreadPool as Pool

from time import sleep

from gentle.util import work


def f(x):
    if x == 0:
        exit(1)
    else:
        print("1")
        sleep(1)


if __name__ == '__main__':
    try:
        work(5, f, range(5), timedelta(minutes=1))
    except SystemExit:
        print("exit")
    except Exception as e:
        print("error")
        print(str(e))


    # with Pool(5) as pool:
    #     try:
    #         print(pool.map(f, range(5)))
    #     except:
    #         print("hi3")
    #     print("hi 2")