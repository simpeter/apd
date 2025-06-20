import os
import json

CONFIG_DIR = "configs"
HYPOTHESIS_FILE = "hypotheses.json"

def generate_configs():
    os.makedirs(CONFIG_DIR, exist_ok=True)
    with open(HYPOTHESIS_FILE) as f:
        hypotheses = json.load(f)

    for h in hypotheses:
        if not h["active"]:
            continue
        if h["id"] == "H1":
            for t in [4, 8, 12, 16]:
                if t in h["tested_values"]:
                    continue
                fname = f"config_{h['id']}_{t}.env"
                with open(os.path.join(CONFIG_DIR, fname), "w") as f:
                    f.write(f"export GRPC_WORKER_THREADS={t}\n")
        elif h["id"] == "H2":
            for ttl in [10, 30, 60]:
                if ttl in h["tested_values"]:
                    continue
                fname = f"config_{h['id']}_{ttl}.env"
                with open(os.path.join(CONFIG_DIR, fname), "w") as f:
                    f.write(f"export REDIS_TTL={ttl}\n")

if __name__ == "__main__":
    generate_configs()
