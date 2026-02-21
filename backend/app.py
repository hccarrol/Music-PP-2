"""
Flask API for Music Sequence Generator
Endpoints: generate, list, serve MIDI, rate, stats
"""

import os
import json
import uuid
from pathlib import Path

from flask import Flask, jsonify, request, send_file, abort
from flask_cors import CORS
import psycopg2
from psycopg2.extras import RealDictCursor, Json
import pretty_midi

# Add parent dir to path so we can import generators
import sys
sys.path.insert(0, str(Path(__file__).parent))
from generators.midi_generator import MidiSequenceGenerator, SequenceConfig, generate_batch

# ─────────────────────────────────────────────
# App Setup
# ─────────────────────────────────────────────

app = Flask(__name__)
CORS(app)

SEQUENCES_DIR = os.environ.get("SEQUENCES_DIR", "./sequences")
os.makedirs(SEQUENCES_DIR, exist_ok=True)

DATABASE_URL = os.environ.get(
    "DATABASE_URL",
    "postgresql://postgres:password@localhost:5432/music_gen"
)


def get_db():
    conn = psycopg2.connect(DATABASE_URL)
    conn.autocommit = False
    return conn


# ─────────────────────────────────────────────
# DB Helper: insert sequence
# ─────────────────────────────────────────────

def insert_sequence(conn, pm: pretty_midi.PrettyMIDI, metadata: dict) -> dict:
    cfg = metadata["config"]
    stats = metadata["stats"]

    with conn.cursor(cursor_factory=RealDictCursor) as cur:
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
                %s, %s, %s,
                %s, %s, %s,
                %s, %s, %s,
                %s, %s, %s,
                %s, %s, %s,
                %s, %s, %s,
                %s, %s, %s
            )
            RETURNING *
        """, (
            metadata["id"],
            metadata["filename"],
            metadata["file_path"],
            cfg["key"], cfg["scale"], cfg["tempo"],
            cfg["time_signature_num"], cfg["time_signature_den"], cfg["num_bars"],
            cfg["octave_range"][0], cfg["octave_range"][1], cfg["rhythm_pattern"],
            cfg["note_duration_variety"], cfg["rest_probability"], cfg["instrument"],
            cfg["velocity_variation"],
            stats["note_count"], stats["duration_seconds"],
            stats["pitch_histogram"],
            Json(cfg), Json(stats),
        ))
        row = cur.fetchone()
    conn.commit()
    return dict(row)


# ─────────────────────────────────────────────
# Routes
# ─────────────────────────────────────────────

@app.route("/api/health")
def health():
    return jsonify({"status": "ok"})


@app.route("/api/sequences/generate", methods=["POST"])
def generate_sequence():
    """Generate a single MIDI sequence with given or random config."""
    body = request.get_json(silent=True) or {}

    if body.get("random", True):
        config = SequenceConfig.random()
        # Allow partial overrides
        for key, val in body.items():
            if key != "random" and hasattr(config, key):
                setattr(config, key, val)
    else:
        config = SequenceConfig.from_dict(body)

    gen = MidiSequenceGenerator(config)
    pm, metadata = gen.generate()

    filepath = os.path.join(SEQUENCES_DIR, metadata["filename"])
    pm.write(filepath)
    metadata["file_path"] = filepath

    try:
        conn = get_db()
        row = insert_sequence(conn, pm, metadata)
        conn.close()
        return jsonify({"success": True, "sequence": row}), 201
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


@app.route("/api/sequences/batch", methods=["POST"])
def batch_generate():
    """Generate N random sequences and store them all."""
    body = request.get_json(silent=True) or {}
    count = min(int(body.get("count", 10)), 100)  # max 100 per call

    conn = get_db()
    inserted = 0
    errors = []

    for i in range(count):
        try:
            config = SequenceConfig.random()
            gen = MidiSequenceGenerator(config)
            pm, metadata = gen.generate()
            filepath = os.path.join(SEQUENCES_DIR, metadata["filename"])
            pm.write(filepath)
            metadata["file_path"] = filepath
            insert_sequence(conn, pm, metadata)
            inserted += 1
        except Exception as e:
            errors.append(str(e))

    conn.close()
    return jsonify({"inserted": inserted, "errors": errors}), 201


@app.route("/api/sequences", methods=["GET"])
def list_sequences():
    """List sequences, with optional filters. Returns unrated ones first by default."""
    page = int(request.args.get("page", 1))
    per_page = min(int(request.args.get("per_page", 20)), 100)
    unrated_first = request.args.get("unrated_first", "true").lower() == "true"
    scale = request.args.get("scale")
    key = request.args.get("key")

    offset = (page - 1) * per_page
    filters = []
    params = []

    if scale:
        filters.append("s.scale = %s")
        params.append(scale)
    if key:
        filters.append("s.key_signature = %s")
        params.append(key)

    where_clause = ("WHERE " + " AND ".join(filters)) if filters else ""

    order = "s.rating_count ASC, s.created_at DESC" if unrated_first else "s.created_at DESC"

    params += [per_page, offset]

    try:
        conn = get_db()
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute(f"""
                SELECT s.*, COUNT(r.id)::int as rating_count, ROUND(AVG(r.rating), 2) as avg_rating
                FROM sequences s
                LEFT JOIN ratings r ON r.sequence_id = s.id
                {where_clause}
                GROUP BY s.id
                ORDER BY {order}
                LIMIT %s OFFSET %s
            """, params)
            rows = [dict(r) for r in cur.fetchall()]

            cur.execute("SELECT COUNT(*) FROM sequences")
            total = cur.fetchone()["count"]

        conn.close()
        return jsonify({"sequences": rows, "total": total, "page": page, "per_page": per_page})
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/api/sequences/<seq_id>", methods=["GET"])
def get_sequence(seq_id):
    try:
        conn = get_db()
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("""
                SELECT s.*, COUNT(r.id)::int as rating_count, ROUND(AVG(r.rating),2) as avg_rating
                FROM sequences s
                LEFT JOIN ratings r ON r.sequence_id = s.id
                WHERE s.id = %s
                GROUP BY s.id
            """, (seq_id,))
            row = cur.fetchone()
        conn.close()
        if not row:
            abort(404)
        return jsonify(dict(row))
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/api/sequences/<seq_id>/midi")
def serve_midi(seq_id):
    """Serve the raw MIDI file for a sequence."""
    try:
        conn = get_db()
        with conn.cursor() as cur:
            cur.execute("SELECT file_path, filename FROM sequences WHERE id = %s", (seq_id,))
            row = cur.fetchone()
        conn.close()
        if not row:
            abort(404)
        file_path, filename = row
        return send_file(file_path, mimetype="audio/midi", download_name=filename)
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/api/sequences/<seq_id>/rate", methods=["POST"])
def rate_sequence(seq_id):
    """Submit a 1-5 star rating for a sequence."""
    body = request.get_json(silent=True) or {}
    rating = body.get("rating")
    notes = body.get("notes", "")
    listen_duration = body.get("listen_duration")

    if not rating or not (1 <= int(rating) <= 5):
        return jsonify({"error": "rating must be 1–5"}), 400

    try:
        conn = get_db()
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("""
                INSERT INTO ratings (sequence_id, rating, notes, listen_duration)
                VALUES (%s, %s, %s, %s)
                RETURNING *
            """, (seq_id, int(rating), notes, listen_duration))
            row = cur.fetchone()
        conn.commit()
        conn.close()
        return jsonify({"success": True, "rating": dict(row)}), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/api/stats")
def stats():
    """Dashboard stats: totals, rating distribution, top scales, etc."""
    try:
        conn = get_db()
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("SELECT COUNT(*) as total FROM sequences")
            total_seqs = cur.fetchone()["total"]

            cur.execute("SELECT COUNT(*) as total FROM ratings")
            total_ratings = cur.fetchone()["total"]

            cur.execute("""
                SELECT rating, COUNT(*) as count
                FROM ratings GROUP BY rating ORDER BY rating
            """)
            rating_dist = {r["rating"]: r["count"] for r in cur.fetchall()}

            cur.execute("""
                SELECT scale, COUNT(*) as count, ROUND(AVG(r.rating), 2) as avg_rating
                FROM sequences s LEFT JOIN ratings r ON r.sequence_id = s.id
                GROUP BY scale ORDER BY avg_rating DESC NULLS LAST
            """)
            scale_stats = [dict(r) for r in cur.fetchall()]

            cur.execute("""
                SELECT COUNT(*) as unrated
                FROM sequences s
                WHERE NOT EXISTS (SELECT 1 FROM ratings r WHERE r.sequence_id = s.id)
            """)
            unrated = cur.fetchone()["unrated"]

        conn.close()
        return jsonify({
            "total_sequences": total_seqs,
            "total_ratings": total_ratings,
            "unrated_sequences": unrated,
            "rated_sequences": total_seqs - unrated,
            "rating_distribution": rating_dist,
            "scale_stats": scale_stats,
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500


if __name__ == "__main__":
    app.run(debug=True, port=5000)
