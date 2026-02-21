-- ============================================================
-- Music Sequence Generator & Rating System
-- PostgreSQL Schema
-- ============================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ─────────────────────────────────────────────
-- Sequences table: stores every generated MIDI sequence
-- ─────────────────────────────────────────────
CREATE TABLE sequences (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    filename        VARCHAR(255) NOT NULL UNIQUE,
    file_path       TEXT NOT NULL,

    -- Musical parameters (indexed for ML feature queries)
    key_signature   VARCHAR(3) NOT NULL,
    scale           VARCHAR(30) NOT NULL,
    tempo           INTEGER NOT NULL CHECK (tempo BETWEEN 40 AND 300),
    time_sig_num    SMALLINT NOT NULL,
    time_sig_den    SMALLINT NOT NULL,
    num_bars        SMALLINT NOT NULL CHECK (num_bars BETWEEN 4 AND 16),
    octave_low      SMALLINT NOT NULL,
    octave_high     SMALLINT NOT NULL,
    rhythm_pattern  VARCHAR(30) NOT NULL,
    duration_variety VARCHAR(10) NOT NULL,
    rest_probability NUMERIC(4,3) NOT NULL,
    instrument      SMALLINT NOT NULL DEFAULT 0,
    velocity_variation BOOLEAN NOT NULL DEFAULT TRUE,

    -- Computed stats from generation
    note_count      INTEGER,
    duration_seconds NUMERIC(8,2),
    pitch_histogram INTEGER[],   -- 12-element array, one per chromatic pitch class

    -- Full config + stats blob for flexibility
    config_json     JSONB NOT NULL,
    stats_json      JSONB,

    -- Timestamps
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for common ML feature queries
CREATE INDEX idx_sequences_key      ON sequences (key_signature);
CREATE INDEX idx_sequences_scale    ON sequences (scale);
CREATE INDEX idx_sequences_tempo    ON sequences (tempo);
CREATE INDEX idx_sequences_bars     ON sequences (num_bars);
CREATE INDEX idx_sequences_created  ON sequences (created_at DESC);
CREATE INDEX idx_sequences_config   ON sequences USING gin (config_json);


-- ─────────────────────────────────────────────
-- Ratings table: 1-5 star ratings with optional notes
-- ─────────────────────────────────────────────
CREATE TABLE ratings (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sequence_id     UUID NOT NULL REFERENCES sequences (id) ON DELETE CASCADE,
    rating          SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    notes           TEXT,                    -- optional free-text comment
    listen_duration  NUMERIC(6,2),           -- seconds listened before rating
    rated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_ratings_sequence   ON ratings (sequence_id);
CREATE INDEX idx_ratings_rating     ON ratings (rating);
CREATE INDEX idx_ratings_rated_at   ON ratings (rated_at DESC);


-- ─────────────────────────────────────────────
-- Aggregate view: sequences with their average rating
-- (used by ML training pipeline)
-- ─────────────────────────────────────────────
CREATE VIEW sequences_with_ratings AS
SELECT
    s.*,
    COUNT(r.id)::INTEGER        AS rating_count,
    ROUND(AVG(r.rating), 3)     AS avg_rating,
    MIN(r.rating)               AS min_rating,
    MAX(r.rating)               AS max_rating
FROM sequences s
LEFT JOIN ratings r ON r.sequence_id = s.id
GROUP BY s.id;


-- ─────────────────────────────────────────────
-- ML training export view
-- Returns flat feature vector + label (avg_rating)
-- ─────────────────────────────────────────────
CREATE VIEW ml_training_data AS
SELECT
    s.id,
    -- Numerical features
    s.tempo,
    s.num_bars,
    s.octave_low,
    s.octave_high,
    s.rest_probability,
    s.note_count,
    s.duration_seconds,
    -- Categorical (will be one-hot encoded in Python)
    s.key_signature,
    s.scale,
    s.rhythm_pattern,
    s.duration_variety,
    s.instrument,
    s.time_sig_num,
    s.time_sig_den,
    s.velocity_variation,
    -- Label
    ROUND(AVG(r.rating), 3)     AS avg_rating,
    COUNT(r.id)::INTEGER        AS rating_count
FROM sequences s
JOIN ratings r ON r.sequence_id = s.id
GROUP BY s.id
HAVING COUNT(r.id) >= 1;  -- only rated sequences


-- ─────────────────────────────────────────────
-- Auto-update updated_at
-- ─────────────────────────────────────────────
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_sequences_updated_at
    BEFORE UPDATE ON sequences
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();


-- ─────────────────────────────────────────────
-- Playback sessions (optional: track listening behavior)
-- ─────────────────────────────────────────────
CREATE TABLE playback_sessions (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sequence_id     UUID NOT NULL REFERENCES sequences (id) ON DELETE CASCADE,
    started_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ended_at        TIMESTAMPTZ,
    completed       BOOLEAN NOT NULL DEFAULT FALSE  -- did user listen to the end?
);

CREATE INDEX idx_playback_sequence ON playback_sessions (sequence_id);
