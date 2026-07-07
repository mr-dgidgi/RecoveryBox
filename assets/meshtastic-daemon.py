#!/data/meshtastic_env/bin/python3
import json
import os
import sys

# Configuration
NODE_IP = ""
OUTPUT_PATH = "/data/brouter/www/meshtastic_nodes.json"
TEMP_PATH = f"{OUTPUT_PATH}.tmp"

try:
    NODE_IP = sys.argv[1]
except IndexError:
    print(f"Usage: {sys.argv[0]} <NODE_IP>", file=sys.stderr)
    sys.exit(1)

# Temporarily silence stderr during Meshtastic initialization to avoid startup noise.
stderr_fd = sys.stderr.fileno()
saved_stderr = os.dup(stderr_fd)
devnull = os.open(os.devnull, os.O_WRONLY)

interface = None
try:
    os.dup2(devnull, stderr_fd)
    from meshtastic.tcp_interface import TCPInterface

    interface = TCPInterface(hostname=NODE_IP)
finally:
    os.dup2(saved_stderr, stderr_fd)
    os.close(devnull)
    os.close(saved_stderr)

features = []

if interface is not None:
    # interface.nodes contains the dictionary of all known nodes.
    for node_data in interface.nodes.values():
        user = node_data.get("user", {})
        position = node_data.get("position", {})
        metrics = node_data.get("deviceMetrics", {})

        lat = position.get("latitude")
        lon = position.get("longitude")

        # Keep only nodes with valid coordinates.
        if lat is not None and lon is not None:
            feature = {
                "type": "Feature",
                "geometry": {
                    "type": "Point",
                    "coordinates": [float(lon), float(lat)],
                },
                "properties": {
                    "name": user.get("longName", user.get("id", "Unknown")),
                    "id": user.get("id", "N/A"),
                    "battery": metrics.get("batteryLevel", "N/A"),
                    "snr": position.get("snr", "N/A"),
                    "lastHeard": node_data.get("lastHeard", "N/A"),
                },
            }
            features.append(feature)

    try:
        interface.close()
    except Exception:
        pass

# Create the final GeoJSON document.
geojson_data = {
    "type": "FeatureCollection",
    "features": features,
}

# Atomic write
try:
    with open(TEMP_PATH, "w", encoding="utf-8") as handle:
        json.dump(geojson_data, handle, ensure_ascii=False, indent=2)

    os.replace(TEMP_PATH, OUTPUT_PATH)
    print(f"GeoJSON updated successfully: {len(features)} nodes with a valid position.")
except Exception as exc:
    print(f"Error while writing output file: {exc}", file=sys.stderr)
    sys.exit(1)

# Exit immediately to avoid leaving behind stray threads.
os._exit(0)
