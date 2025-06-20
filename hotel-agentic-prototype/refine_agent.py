import subprocess
import json

while True:
    print("🌀 Generating new configs...")
    subprocess.run(["python3", "scripts/generate_configs.py"])

    print("🚀 Running benchmarks...")
    subprocess.run(["python3", "agentctl.py"])

    print("🔍 Refining hypotheses...")
    subprocess.run(["python3", "scripts/refine_hypotheses.py"])

    with open("hypotheses.json") as f:
        hypotheses = json.load(f)
        if not any(h["active"] for h in hypotheses):
            print("✅ All hypotheses tested. Stopping.")
            break
