import matplotlib.pyplot as plt
import numpy as np

def draw(latency_dict, title, error_type):
  fig = plt.figure(figsize =(15, 5))
  rate = sorted(latency_dict.keys())
  y = []
  std = []
  for r in rate:
    latency = np.array(latency_dict[r])
    y.append(np.average(latency))
    std.append(np.std(latency))

  # Plot error bar
  plt.errorbar(rate, y, yerr = std, fmt = '-o',color = 'black', 
              ecolor = 'black', elinewidth = 2, capsize=5)
  plt.xticks(rate)
  plt.ylabel("Latency(ms)")
  plt.xlabel("Request Rate(Req/Sec)")
  plt.title(title)

  # Display graph
  plt.show()

if __name__ == "__main__":
    # Format: {rate: [latency1, latency2...]} (e.g., {100:[11,10,23], 200:[12,20,22])
    # Rate = Request per second and Latency = latency in microsecond
    baremetal = {} # Add your result here
    draw(baremetal, "Bare Mental")

    vm = {} # Add your result here
    draw(vm, "Virtual Machine")

    vm_passthrough = {} # Add your result here
    draw(vm_passthrough, "Virtual Machine (Passthrough)")

    vm_trap_emulate = {} # Add your result here
    draw(vm_passthrough, "Virtual Machine (Trap&Emulate)")