import sys
import json

def parse_wrk_output(filename):
    with open(filename, 'r') as f:
        lines = f.readlines()
    
    result = {"throughput": 0, "p95_latency_ms": 0}
    for line in lines:
        if "Completed Requests/sec" in line:
            result["throughput"] = float(line.strip().split(":")[1])
        elif "Latency" in line and "Thread Stats" not in line:
            parts = line.strip().split()
            if len(parts) >= 4:
                latency_str = parts[3]  # 99% value
                if latency_str.endswith("ms"):
                    result["p95_latency_ms"] = float(latency_str.replace("ms", ""))
                elif latency_str.endswith("us"):
                    result["p95_latency_ms"] = float(latency_str.replace("us", "")) / 1000
                elif latency_str.endswith("s"):
                    result["p95_latency_ms"] = float(latency_str.replace("s", "")) * 1000
    return result

if __name__ == "__main__":
    output = parse_wrk_output(sys.argv[1])
    print(json.dumps(output, indent=2))
