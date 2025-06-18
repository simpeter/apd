import os

hypotheses = [
    {"id": "H1", "name": "frontend_grpc_threads", "values": [4, 8, 12, 16]},
    {"id": "H2", "name": "redis_ttl", "values": [10, 30, 60]}
]

def generate_configs(output_dir="configs"):
    os.makedirs(output_dir, exist_ok=True)
    for h in hypotheses:
        for val in h["values"]:
            fname = f"config_{h['id']}_{val}.env"
            with open(os.path.join(output_dir, fname), "w") as f:
                if h["id"] == "H1":
                    f.write(f"export GRPC_WORKER_THREADS={val}\n")
                elif h["id"] == "H2":
                    f.write(f"export REDIS_TTL={val}\n")

if __name__ == "__main__":
    generate_configs()
