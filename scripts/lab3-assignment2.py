import matplotlib.pyplot as plt
import numpy as np

if __name__ == "__main__":
    data = []

    with open("lat.txt") as file:  # TODO: Add your output file here
        lines = file.readlines()
        data.extend([line.rstrip() for line in lines])
    
    x, y = [], []
    # TODO: Parse the wrk2 output here. x should be a list of timestamps and y should be a list of latencies
    # Note: 1) Convert timestamps and latencies us to ms 2) subtract the timestamp of the first request
    # from the timestamp of the following requests
    
    x = np.array(x)
    y = np.array(y)
    plt.axhline(y=500, color='blue', linestyle='-')
    plt.xlabel("Time (ms)")
    plt.ylabel("Latency (ms)")
    plt.scatter(x, y)
    plt.savefig("NAME_OF_YOUR_FIGURE.png") # TODO: name your figure here