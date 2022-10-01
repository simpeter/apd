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
  plt.axhline(y=500, color='blue', linestyle='-')
  plt.xlabel("Request Rate(Req/Sec)")
  plt.title(title)

  # Display graph
  plt.show()

if __name__ == "__main__":
    # Format: {rate: [latency1, latency2...]} (e.g., {100:[11,10,23], 200:[12,20,22])
    # Rate = Request per second and Latency = latency in microsecond
    baremetal_tenant1 = {} # TODO: Add your result here
    baremetal_tenant2 = {} # TODO: Add your result here
    draw(baremetal_tenant1, "Bare_Mental_Tenant1")
    draw(baremetal_tenant2, "Bare_Mental_Tenant2")

    vm_tenant1 = {} # TODO: Add your result here
    vm_tenant2 = {} # TODO: Add your result here
    draw(vm_tenant1, "Virtual_Machine_Tenant1")
    draw(vm_tenant2, "Virtual_Machine_Tenant2")

