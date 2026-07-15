import csv
import json
import re
from collections import Counter

# ============================================================
#  SONIQ — Validate Seed Database (Signal 2)
#  STAGE 2.3 & 2.4 (Bug Fix & Native Upgrades)
# ============================================================

def split_and_normalize(raw_artist):
    # 1. Split the string by English, Hindi, Kannada, and Tamil delimiters
    parts = re.split(r'\s+&\s+|\s+and\s+|,|\s+और\s+|\s+ಮತ್ತು\s+|\s+மற்றும்\s+', raw_artist.lower())
    
    normalized_parts = []
    for p in parts:
        s = p
        s = re.sub(r'\bfeat\.?\b.*', '', s)   
        s = re.sub(r'\bft\.?\b.*', '', s)     
        s = re.sub(r'\.', '', s)              
        s = re.sub(r'[!@#$%\^&*()\-_=+[\]{};:\'",<>/?\\|]', ' ', s)
        s = re.sub(r'\s+', ' ', s)            
        s = s.strip()
        if s:
            normalized_parts.append(s)
    
    return normalized_parts

def validate_seed_db():
    db_path = 'assets/seed_db_v1.json'
    csv_path = 'test_data/validation_set.csv'
    
    try:
        with open(db_path, 'r', encoding='utf-8') as f:
            seed_db = json.load(f)
    except FileNotFoundError:
        print("❌ Error: Could not find seed_db_v1.json")
        return

    total_songs = 0
    matched_songs = 0
    correct_matches = 0
    missed_artists = Counter()

    try:
        with open(csv_path, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                total_songs += 1
                raw_artist = row['artist']
                true_language = row['true_language']
                
                # Get a list of normalized individual artists
                artist_list = split_and_normalize(raw_artist)
                song_matched = False
                
                # Check if ANY artist in the duet exists in our DB
                for artist in artist_list:
                    if artist in seed_db:
                        song_matched = True
                        matched_songs += 1  # <--- THE MISSING COUNTER!
                        scores = seed_db[artist]['scores']
                        predicted = max(scores, key=scores.get)
                        
                        if predicted == true_language:
                            correct_matches += 1
                        break # Once we match the song, stop checking the other duet members
                
                if not song_matched:
                    missed_artists[raw_artist] += 1
                    
    except FileNotFoundError:
        print("❌ Error: Could not find validation_set.csv")
        return

    coverage = (matched_songs / total_songs) * 100 if total_songs > 0 else 0
    accuracy = (correct_matches / matched_songs) * 100 if matched_songs > 0 else 0

    print("=== CLASSIFIER SIGNAL 2: SEED DB VALIDATION ===")
    print(f"Total songs tested : {total_songs}")
    print(f"Signal 2 coverage  : {coverage:.1f}% ({matched_songs}/{total_songs})")
    if matched_songs > 0:
        print(f"Signal 2 accuracy  : {accuracy:.1f}% ({correct_matches}/{matched_songs} correct when fired)")
    
    print("\n--- TOP 10 MISSING ARTISTS ---")
    for artist, count in missed_artists.most_common(10):
        print(f"Raw: '{artist}'")

if __name__ == '__main__':
    validate_seed_db()