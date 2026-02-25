#!/usr/bin/env python3
"""
CLI tool to quickly generate sequences and optionally seed the database.

Usage:
    python cli_generate.py --count 100 --output ./sequences
    python cli_generate.py --count 50 --db-url postgresql://... --seed-db
"""

import argparse
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from generators.midi_generator import generate_batch, SequenceConfig, MidiSequenceGenerator


def seed_database(metadata_list: list[dict], db_url: str):
    import psycopg2
    from psycopg2.extras import Json

    conn = psycopg2.connect(db_url)
    cur = conn.cursor()
    inserted = 0

    for meta in metadata_list:
        cfg = meta["config"]
        stats = meta["stats"]
        try:
            cur.execute("""
                INSERT INTO sequences (
                    id, filename, file_path,
                    key_signature, scale, tempo,
                    time_sig_num, time_sig_den, num_bars,
                    octave_low, octave_high, rhythm_pattern,
                    duration_variety, rest_probability, instrument,
                    velocity_variation, note_count, duration_seconds,
                    pitch_histogram, config_json, stats_json
                ) VALUES (
                    %s, %s, %s, %s, %s, %s, %s, %s, %s,
                    %s, %s, %s, %s, %s, %s, %s, %s, %s,
                    %s, %s, %s
                ) ON CONFLICT (id) DO NOTHING
            """, (
                meta["id"], meta["filename"], meta["file_path"],
                cfg["key"], cfg["scale"], cfg["tempo"],
                cfg["time_signature_num"], cfg["time_signature_den"], cfg["num_bars"],
                cfg["octave_range"][0], cfg["octave_range"][1], cfg["rhythm_pattern"],
                cfg["note_duration_variety"], cfg["rest_probability"], cfg["instrument"],
                cfg["velocity_variation"],
                stats["note_count"], stats["duration_seconds"],
                stats["pitch_histogram"],
                Json(cfg), Json(stats),
            ))
            inserted += 1
        except Exception as e:
            print(f"  ⚠️  Skipped {meta['id']}: {e}")

    conn.commit()
    cur.close()
    conn.close()
    return inserted


def main():
    parser = argparse.ArgumentParser(description="Generate MIDI sequences for MusicGen")
    parser.add_argument("--count", type=int, default=50, help="Number of sequences to generate")
    parser.add_argument("--output", type=str, default="./sequences", help="Output directory")
    parser.add_argument("--seed-db", action="store_true", help="Insert sequences into PostgreSQL")
    parser.add_argument(
        "--db-url",
        type=str,
        default="postgresql://postgres:password@localhost:5432/music_gen",
        help="PostgreSQL connection string"
    )
    args = parser.parse_args()

    print(f"\n🎵 Generating {args.count} sequences into '{args.output}/'...\n")
    metadata_list = generate_batch(args.count, output_dir=args.output, randomize=True)

    if args.seed_db:
        print(f"\n📦 Seeding database at {args.db_url}...")
        inserted = seed_database(metadata_list, args.db_url)
        print(f"   ✅ Inserted {inserted}/{len(metadata_list)} sequences into PostgreSQL")

    print(f"\n🎉 Done! {len(metadata_list)} sequences ready for rating.\n")


if __name__ == "__main__":
    main()