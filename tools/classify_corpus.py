import csv
import json
import re
from collections import Counter

# ============================================================
#  SONIQ — Master Unified Classifier (Signals 1 + 2)
#  STAGE 3.1
# ============================================================

def split_and_normalize(raw_artist):
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

def get_signal_1_path(filename):
    # Extracts language hints from folders/paths or bracket tags in filename
    s = filename.lower()
    if 'hindi' in s or '[hi]' in s: return 'Hindi'
    if 'kannada' in s or '[kn]' in s: return 'Kannada'
    if 'tamil' in s or '[ta]' in s: return 'Tamil'
    if 'telugu' in s or '[te]' in s: return 'Telugu'
    if 'punjabi' in s or '[pa]' in s: return 'Punjabi'
    if 'english' in s or 'global' in s or '[en]' in s: return 'English'
    return None

def classify_song(filename, raw_artist, seed_db):
    # Strategy: Signal 2 (Artist DB) takes priority, falls back to Signal 1 (Path)
    
    # 1. Try Signal 2: Seed DB lookup
    artist_list = split_and_normalize(raw_artist)
    for artist in artist_list:
        if artist in seed_db:
            scores = seed_db[artist]['scores']
            predicted_lang = max(scores, key=scores.get)
            return predicted_lang, "Signal 2 (Artist DB)"
            
    # 2. Try Signal 1: Path fallback
    path_hint = get_signal_1_path(filename)
    if path_hint:
        return path_hint, "Signal 1 (Folder Path)"
        
    # 3. Default Fallback
    return "Hindi", "Default Fallback"

def run_master_classification():
    db_path = 'assets/seed_db_v1.json'
    csv_path = 'test_data/validation_set.csv'
    
    try:
        with open(db_path, 'r', encoding='utf-8') as f:
            seed_db = json.load(f)
    except FileNotFoundError:
        print("❌ Error: Could not find seed_db_v1.json")
        return

    total = 0
    correct = 0
    signal_distribution = Counter()
    failures = []

    try:
        with open(csv_path, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                total += 1
                filename = row['filename']
                raw_artist = row['artist']
                true_language = row['true_language']
                
                predicted_lang, signal_used = classify_song(filename, raw_artist, seed_db)
                signal_distribution[signal_used] += 1
                
                if predicted_lang == true_language:
                    correct += 1
                else:
                    failures.append({
                        "filename": filename,
                        "artist": raw_artist,
                        "true": true_language,
                        "pred": predicted_lang,
                        "signal": signal_used
                    })
    except FileNotFoundError:
        print("❌ Error: Could not find validation_set.csv")
        return

    accuracy = (correct / total) * 100 if total > 0 else 0
    
    print("\n==============================================")
    print("       SONIQ MASTER ENGINE RUN RESULTS        ")
    print("==============================================")
    print(f"Total Songs Evaluated : {total}")
    print(f"Overall Pipeline Acc  : {accuracy:.2f}% ({correct}/{total})")
    print("\n--- Signal Firing Breakdown ---")
    for sig, count in signal_distribution.items():
        print(f" -> {sig}: {count} songs ({(count/total)*100:.1f}%)")
        
    if failures:
        print("\n--- Sample Pipeline Failures (Top 5) ---")
        for f in failures[:5]:
            print(f"File: {f['filename']} | Artist: {f['artist']} | True: {f['true']} | Pred: {f['pred']} ({f['signal']})")

if __name__ == '__main__':
    run_master_classification()