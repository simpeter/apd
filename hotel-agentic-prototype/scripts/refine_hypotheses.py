import json

with open("results/summary.json") as f:
    summary = json.load(f)

with open("hypotheses.json") as f:
    hypotheses = json.load(f)

for h in hypotheses:
    print(f"\n🔍 Evaluating hypothesis {h['id']}: {h['description']}")
    tested = [d for d in summary["all"] if h["id"] in d["config"]]
    seen_values = set(int(d["config"].split("_")[-1].replace(".env", "")) for d in tested)
    h["tested_values"] = sorted(list(seen_values))

    valid = [d for d in tested if d["p95_latency_ms"] < 500]

    if not valid:
        print(f"❌ No configs met latency SLO for {h['id']}. Deactivating.")
        h["active"] = False
    else:
        best = max(valid, key=lambda x: x["throughput"])
        print(f"✅ Best config under SLO: {best['config']}")
        h["best"] = best["config"]

        # Check if all values have been tested
        if h["id"] == "H1":
            full = set([4, 8, 12, 16])
        elif h["id"] == "H2":
            full = set([10, 30, 60])
        else:
            full = set()

        if seen_values >= full:
            print(f"🛑 All values tested for {h['id']}. Deactivating.")
            h["active"] = False
        else:
            h["active"] = True

with open("hypotheses.json", "w") as f:
    json.dump(hypotheses, f, indent=2)
