#!/usr/bin/env python3
# ============================================================
#  SONIQ — tools/validate_seed.py
#  Validates seed database structure and updates manifest.json
# ============================================================

import json
import sys
import hashlib
import os
import argparse

def compute_sha256(file_path):
    sha256 = hashlib.sha256()
    with open(file_path, 'rb') as f:
        while chunk := f.read(8192):
            sha256.update(chunk)
    return sha256.hexdigest()

def validate_and_update(seed_path, update_manifest):
    print(f"🔍 Validating seed file: {seed_path}")
    
    if not os.path.exists(seed_path):
        print(f"❌ Error: File not found at {seed_path}")
        sys.exit(1)
        
    try:
        with open(seed_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except json.JSONDecodeError as e:
        print(f"❌ Error: Invalid JSON syntax: {e}")
        sys.exit(1)

    # 1. Structural Checks
    if not isinstance(data, dict):
        print("❌ Error: Top-level structure must be a JSON object.")
        sys.exit(1)
        
    if "version" not in data or not isinstance(data["version"], int):
        print("❌ Error: Missing or invalid top-level integer 'version'.")
        sys.exit(1)
        
    if "artists" not in data or not isinstance(data["artists"], dict):
        print("❌ Error: Missing or invalid top-level object 'artists'.")
        sys.exit(1)

    # 2. Key Content & Value Verification
    artists = data["artists"]
    print(f"📊 Found {len(artists)} artist profiles in seed.")
    
    for artist, languages in artists.items():
        if artist != artist.lower().strip():
            print(f"❌ Error: Artist key '{artist}' must be lowercase and trimmed.")
            sys.exit(1)
            
        if not isinstance(languages, dict) or not languages:
            print(f"❌ Error: Artist '{artist}' must have a non-empty language map.")
            sys.exit(1)
            
        for lang, weight in languages.items():
            if not isinstance(weight, (int, float)) or not (0.0 <= weight <= 1.0):
                print(f"❌ Error: Artist '{artist}' language '{lang}' weight must be between 0.0 and 1.0.")
                sys.exit(1)

    print("✅ Schema and constraints validation passed successfully.")

    # 3. Handle Manifest Automation
    if update_manifest:
        manifest_path = "manifest.json"
        if not os.path.exists(manifest_path):
            print(f"❌ Error: {manifest_path} missing from repository root.")
            sys.exit(1)
            
        with open(manifest_path, 'r', encoding='utf-8') as f:
            manifest = json.load(f)
            
        checksum = compute_sha256(seed_path)
        size_bytes = os.path.getsize(seed_path)
        
        manifest["version"] = data["version"]
        manifest["url"] = f"https://raw.githubusercontent.com/YOUR_GITHUB_USERNAME/soniq-data/main/{os.path.basename(seed_path)}"
        manifest["checksum_sha256"] = checksum
        manifest["size_bytes"] = size_bytes
        
        with open(manifest_path, 'w', encoding='utf-8') as f:
            json.dump(manifest, f, indent=2)
            
        print(f"✨ Auto-updated manifest.json to version {data['version']} with hash: {checksum}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("seed_file", help="Path to the seed_db_v*.json file")
    parser.add_argument("--update-manifest", action="store_true", help="Update production manifest parameters")
    args = parser.parse_args()
    
    validate_and_update(args.seed_file, args.update_manifest)