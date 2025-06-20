import matplotlib.pyplot as plt
import numpy as np


def draw(latency_dict, title):
  plt.figure(figsize=(10, 5))
  rate = latency_dict.keys()
  y = []
  std = []
  for r in rate:
    latency = np.array(latency_dict[r])
    y.append(np.average(latency))
    std.append(np.std(latency))

  # Plot error bar
  plt.errorbar(rate, y, yerr=std, fmt='-o', color='black',
                ecolor='black', elinewidth=2, capsize=5)
  plt.xticks(sorted(rate))
  plt.ylabel("Latency (ms)")
  plt.axhline(y=500, color='blue', linestyle='-')
  plt.xlabel("Throughput (Req/Sec)")
  plt.title(title)

  # Display graph
  plt.savefig(title + ".png")

if __name__ == "__main__":
  # Format: {throughput: [latency1, latency2...]} (e.g., {100:[11,10,23], 200:[12,20,22])
  # Throughput = completed Request per second and Latency = latency in microsecond. 
  baremetal_one_server = {}  # TODO: Add your result here
  draw(baremetal_one_server, "Bare_Metal_One_Server")