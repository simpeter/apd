import sys
import matplotlib.pyplot as plt
import os
import numpy as np
import glob

import matplotlib

if __name__ == "__main__":
    data = []

    with open("LATENCY_FILE_NAME") as file: # TODO: Add you latency file name here
        lines = file.readlines()
        data.extend([int(line.rstrip()) for line in lines])
        x = [i for i in range(len(data))]

    plt.plot(x,data)
    plt.ylabel("Latency(us)")
    plt.xlabel("Request #")
    plt.savefig("latency_over_time.png")