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
  plt.xlabel("Request Rate (Req/Sec)")
  plt.title(title)

  # Display graph
  plt.savefig(title + ".png")


if __name__ == "__main__":
  # Format: {rate: [latency1, latency2...]} (e.g., {100:[11,10,23], 200:[12,20,22])
  # Rate = Request per second and Latency = latency in microsecond
  baremetal = {}  # TODO: Add your result here
  draw(baremetal, "Bare_Metal")

  vm = {}  # TODO: Add your result here
  draw(vm, "Virtual_Machine")

  vm_passthrough = {}  # TODO: Add your result here
  draw(vm_passthrough, "Virtual_Machine_Passthrough")

  vm_trap_emulate = {}  # TODO: Add your result here
  draw(vm_trap_emulate, "Virtual_Machine_Trap_Emulate")