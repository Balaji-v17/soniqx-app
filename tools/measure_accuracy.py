#!/usr/bin/env python3
# ============================================================
#  SONIQ — tools/measure_accuracy.py
#  Offline Benchmark for Signal 2 (Artist Database)
# ============================================================

import csv
import json
import re
import os
from collections import defaultdict

# Paths
CSV_PATH = '../test_data/validation_set.csv'
JSON_PATH = '../assets/seed_db_v1.json'

def normalize_artist(raw_name):
    """Mirrors the exact Dart string extension logic."""
    if not raw_name:
        return ""
    
    text = str(raw_name).lower()
    # 1. Remove feat/ft and everything after
    text = re.sub(r'\bfeat\.?\b.*', '', text)
    text = re.sub(r'\bft\.?\b.*', '', text)
    # 2. Remove dots
    text = re.sub(r'\.', '', text)
    # 3. Remove special characters
    text = re.sub(r'[^\w\s]', '', text)
    # 4. Collapse spaces and trim
    text = re.sub(r'\s+', ' ', text).strip()
    
    return text

def run_benchmark():
    # 1. Load the Seed Database
    if not os.path.exists(JSON_PATH):
        print(f"🚨 JSON not found at {JSON_PATH}. Run from the tools/ directory.")
        return
        
    with open(JSON_PATH, 'r', encoding='utf-8') as f:
        raw_json = json.load(f)
        # Handle both flat maps and {"artists": {...}} structures
        db = raw_json.get('artists', raw_json) 
        
    print(f"✅ Loaded {len(db)} artists from seed database.")

    # 2. Load the CSV Validation Set
    if not os.path.exists(CSV_PATH):
        print(f"🚨 CSV not found at {CSV_PATH}. Make sure you created Step 1.1!")
        return

    total_tested = 0
    correctly_classified = 0
    
    # Trackers for the report
    lang_stats = defaultdict(lambda: {'tested': 0, 'correct': 0})
    script_stats = {'native': {'tested': 0, 'correct': 0}, 'latin': {'tested': 0, 'correct': 0}}
    confidence_tiers = {'auto': 0, 'suggested': 0, 'manual': 0}

    with open(CSV_PATH, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            true_lang = row.get('true_language', '').strip()
            artist = row.get('artist', '').strip()
            has_native = row.get('has_native_script', 'false').lower() == 'true'
            
            if not true_lang: continue
            
            total_tested += 1
            lang_stats[true_lang]['tested'] += 1
            
            if has_native:
                script_stats['native']['tested'] += 1
            else:
                script_stats['latin']['tested'] += 1

            # The Core AI Logic Simulation
            clean_artist = normalize_artist(artist)
            best_lang = None
            best_score = 0.0
            
            if clean_artist in db:
                scores = db[clean_artist]
                for lang, score in scores.items():
                    if score > best_score:
                        best_score = score
                        best_lang = lang
            
            # Record Accuracy
            is_correct = (best_lang == true_lang)
            if is_correct:
                correctly_classified += 1
                lang_stats[true_lang]['correct'] += 1
                if has_native:
                    script_stats['native']['correct'] += 1
                else:
                    script_stats['latin']['correct'] += 1
            
            # Record Confidence Tiers
            if best_score >= 0.85:
                confidence_tiers['auto'] += 1
            elif best_score >= 0.50:
                confidence_tiers['suggested'] += 1
            else:
                confidence_tiers['manual'] += 1

    # 3. Print the Master Plan Report
    overall_acc = (correctly_classified / total_tested) * 100 if total_tested > 0 else 0
    
    print("\n" + "="*50)
    print("=== CLASSIFIER ACCURACY REPORT (SIGNAL 2) ===")
    print("="*50)
    print(f"Total songs tested       : {total_tested}")
    print(f"Correctly classified     : {correctly_classified}")
    print(f"Overall accuracy         : {overall_acc:.1f}%\n")
    
    print("--- By language ---")
    for lang, stats in sorted(lang_stats.items(), key=lambda x: x[1]['tested'], reverse=True):
        acc = (stats['correct'] / stats['tested']) * 100 if stats['tested'] > 0 else 0
        print(f"{lang:<9} : {acc:>5.0f}% (tested: {stats['tested']:>3})")
        
    print("\n--- By filename type ---")
    for script, stats in script_stats.items():
        name = "Native script" if script == 'native' else "Latin script"
        acc = (stats['correct'] / stats['tested']) * 100 if stats['tested'] > 0 else 0
        print(f"{name:<15}: {acc:>5.0f}% accuracy")
        
    print("\n--- Confidence Band Calibration ---")
    if total_tested > 0:
        print(f"Auto-classified ( > 0.85)    : {(confidence_tiers['auto']/total_tested)*100:>4.1f}% of songs")
        print(f"Suggested       (0.50-0.84)  : {(confidence_tiers['suggested']/total_tested)*100:>4.1f}% of songs")
        print(f"Fell to manual  ( < 0.50)    : {(confidence_tiers['manual']/total_tested)*100:>4.1f}% of songs")
    print("==================================================")

if __name__ == '__main__':
    run_benchmark()