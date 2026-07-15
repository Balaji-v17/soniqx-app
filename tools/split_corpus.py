import pandas as pd
import os

def split_corpus():
    base_dir = 'test_data'
    corpus_path = os.path.join(base_dir, 'language_test_corpus.csv')
    
    # 1. Load the dataset you just built
    df = pd.read_csv(corpus_path)
    
    # 2. Shuffle it randomly (random_state ensures it's reproducible if needed)
    df_shuffled = df.sample(frac=1, random_state=42).reset_index(drop=True)
    
    # 3. Split it (First 400 to Validation, Last 100 to Holdout)
    validation_set = df_shuffled.iloc[:400]
    holdout_set = df_shuffled.iloc[400:]
    
    # 4. Save the new files
    validation_set.to_csv(os.path.join(base_dir, 'validation_set.csv'), index=False)
    holdout_set.to_csv(os.path.join(base_dir, 'holdout_set.csv'), index=False)
    
    print(f"✅ Split Complete!")
    print(f"Validation Set: {len(validation_set)} songs")
    print(f"Holdout Set: {len(holdout_set)} songs")
    print("\n🚨 CRITICAL: Do not open or look at 'holdout_set.csv' until Phase 8 testing.")

if __name__ == "__main__":
    split_corpus()
