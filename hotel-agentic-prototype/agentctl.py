import os
import subprocess
import json

CONFIG_DIR = "configs"
RESULTS = []

for config_file in sorted(os.listdir(CONFIG_DIR)):
    if not config_file.endswith(".env"):
        continue
    config_path = os.path.join(CONFIG_DIR, config_file)
    print(f"Deploying config: {config_file}")
    subprocess.run(["scripts/deploy_config.sh", config_path])
    subprocess.run(["sleep", "10"])  # wait for warm-up

    output_file = "wrk.out"
    with open(output_file, "w") as out:
        subprocess.run(["wrk", "-t2", "-c50", "-d30s", "-R500", "-s", "loadgen/hotel_wrk.lua", "http://server0:5000/reserve"], stdout=out)

    result = subprocess.run(["python3", "scripts/parse_wrk_output.py", output_file], capture_output=True, text=True)
    stats = json.loads(result.stdout)
    stats["config"] = config_file
    RESULTS.append(stats)

# Select best
valid = [r for r in RESULTS if r["p95_latency_ms"] < 500]
best = max(valid, key=lambda r: r["throughput"]) if valid else None

with open("results/summary.json", "w") as f:
    json.dump({"best": best, "all": RESULTS}, f, indent=2)
