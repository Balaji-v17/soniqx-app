import os
import json
import csv

# ============================================================
#  SONIQ — MusicBrainz TSV to JSON Parser
#  STAGE 2.1
# ============================================================

def build_seed_db():
    data_dir = 'musicbrainz_data'
    output_path = 'assets/seed_db_musicbrainz.json'
    
    # Ensure assets directory exists
    os.makedirs('assets', exist_ok=True)
    
    # Step 1: Build area_id → country/region lookup based on the master plan
    area_language_map = {
        "Karnataka": "Kannada",
        "Tamil Nadu": "Tamil",
        "Andhra Pradesh": "Telugu",
        "Telangana": "Telugu",
        "Kerala": "Malayalam",
        "Punjab": "Punjabi",
        "Maharashtra": "Hindi",
        "West Bengal": "Bengali",
        "Rajasthan": "Hindi",
        "Uttar Pradesh": "Hindi",
        "Delhi": "Hindi",
        "India": "Hindi" # India (national) = Hindi as default, confidence 0.6
    }
    
    print("⏳ Parsing MusicBrainz TSV files... (This might take a minute)")
    
    # Load Areas
    area_dict = {}
    try:
        with open(f'{data_dir}/area', 'r', encoding='utf-8') as f:
            reader = csv.reader(f, delimiter='\t')
            for row in reader:
                if len(row) >= 3:
                    area_id = row[0]
                    area_name = row[2]
                    area_dict[area_id] = area_name
    except FileNotFoundError:
        print(f"❌ Error: Could not find 'area' file in {data_dir}/")
        return

    # Load Artists and map to languages
    seed_db = {}
    indian_artist_count = 0
    
    try:
        with open(f'{data_dir}/artist', 'r', encoding='utf-8') as f:
            reader = csv.reader(f, delimiter='\t')
            for row in reader:
                if len(row) >= 12:
                    artist_name = row[2]
                    area_id = row[11] # The area column
                    
                    if area_id in area_dict:
                        region_name = area_dict[area_id]
                        
                        # Filter for Indian regions mapped in our dictionary
                        if region_name in area_language_map:
                            primary_lang = area_language_map[region_name]
                            
                            # Determine confidence
                            confidence_score = 0.6 if region_name == "India" else 0.95
                            
                            normalized_name = artist_name.lower().strip()
                            
                            seed_db[normalized_name] = {
                                "primary_language": primary_lang,
                                "scores": {
                                    primary_lang: confidence_score
                                },
                                "source": "musicbrainz",
                                "confidence": "high" if confidence_score > 0.9 else "medium"
                            }
                            indian_artist_count += 1
    except FileNotFoundError:
        print(f"❌ Error: Could not find 'artist' file in {data_dir}/")
        return

    # Step 4: Export as JSON
    with open(output_path, 'w', encoding='utf-8') as out_f:
        json.dump(seed_db, out_f, indent=2, ensure_ascii=False)
        
    print("✅ MusicBrainz parsing complete!")
    print(f"🎵 Total Indian artists extracted: {indian_artist_count}")
    print(f"📁 Saved to: {output_path}")

if __name__ == "__main__":
    build_seed_db()