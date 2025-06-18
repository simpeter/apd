import sys
import json

def parse_wrk_output(filename):
    with open(filename, 'r') as f:
        lines = f.readlines()

    result = {"throughput": 0, "p95_latency_ms": 0}
    for line in lines:
        if "Requests/sec" in line:
            result["throughput"] = float(line.strip().split(":")[1])
        elif "Latency" in line and "95%" in line:
            result["p95_latency_ms"] = float(line.split()[1].replace("ms", ""))
    return result

if __name__ == "__main__":
    output = parse_wrk_output(sys.argv[1])
    print(json.dumps(output, indent=2))
