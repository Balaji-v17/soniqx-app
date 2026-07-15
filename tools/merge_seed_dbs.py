import json
import os

def merge_databases():
    mb_path = 'assets/seed_db_musicbrainz.json'
    manual_path = 'assets/seed_db_manual.json'
    output_path = 'assets/seed_db_v1.json'

    # Load MB Database
    mb_db = {}
    if os.path.exists(mb_path):
        with open(mb_path, 'r', encoding='utf-8') as f:
            mb_db = json.load(f)
    
    # Load Manual Database
    manual_db = {}
    if os.path.exists(manual_path):
        with open(manual_path, 'r', encoding='utf-8') as f:
            manual_db = json.load(f)

    # The Merge (Manual overrides MB)
    final_db = mb_db.copy()
    final_db.update(manual_db)

    # Save v1
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(final_db, f, indent=2, ensure_ascii=False)

    print("✅ Databases Merged Successfully!")
    print(f"MusicBrainz Entries : {len(mb_db)}")
    print(f"Manual Overrides    : {len(manual_db)}")
    print(f"Total v1 Entries    : {len(final_db)}")
    print(f"Saved to            : {output_path}")

if __name__ == "__main__":
    merge_databases()