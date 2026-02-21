"""
MIDI Sequence Generator
Configurable parameters: key, scale, tempo, time signature, length, rhythm patterns
"""

import random
import json
import uuid
from dataclasses import dataclass, asdict, field
from typing import Optional
from enum import Enum

import pretty_midi
import numpy as np


# ─────────────────────────────────────────────
# Music Theory Constants
# ─────────────────────────────────────────────

SCALE_INTERVALS = {
    "major":      [0, 2, 4, 5, 7, 9, 11],
    "minor":      [0, 2, 3, 5, 7, 8, 10],
    "pentatonic_major": [0, 2, 4, 7, 9],
    "pentatonic_minor": [0, 3, 5, 7, 10],
    "blues":      [0, 3, 5, 6, 7, 10],
    "dorian":     [0, 2, 3, 5, 7, 9, 10],
    "mixolydian": [0, 2, 4, 5, 7, 9, 10],
}

KEY_OFFSETS = {
    "C": 0,  "C#": 1, "Db": 1,
    "D": 2,  "D#": 3, "Eb": 3,
    "E": 4,  "F": 5,  "F#": 6,
    "Gb": 6, "G": 7,  "G#": 8,
    "Ab": 8, "A": 9,  "A#": 10,
    "Bb": 10,"B": 11,
}

RHYTHM_PATTERNS = {
    "straight":    [1.0, 1.0, 1.0, 1.0],
    "dotted":      [1.5, 0.5, 1.5, 0.5],
    "syncopated":  [0.5, 1.0, 1.5, 0.5, 0.5],
    "triplet":     [0.667, 0.667, 0.667],
    "waltz":       [1.5, 0.75, 0.75],
    "swing":       [0.75, 0.25, 0.75, 0.25],
    "mixed":       None,  # randomized per bar
}

NOTE_DURATIONS = {
    "whole":        4.0,
    "half":         2.0,
    "quarter":      1.0,
    "eighth":       0.5,
    "sixteenth":    0.25,
    "dotted_quarter": 1.5,
    "dotted_eighth":  0.75,
}


# ─────────────────────────────────────────────
# Configuration Dataclass
# ─────────────────────────────────────────────

@dataclass
class SequenceConfig:
    key: str = "C"
    scale: str = "major"
    tempo: int = 120
    time_signature_num: int = 4
    time_signature_den: int = 4
    num_bars: int = 8
    octave_range: tuple = (4, 6)
    rhythm_pattern: str = "straight"
    note_duration_variety: str = "medium"  # low / medium / high
    rest_probability: float = 0.1
    velocity_variation: bool = True
    instrument: int = 0  # GM program number (0 = piano)

    def to_dict(self) -> dict:
        d = asdict(self)
        d["octave_range"] = list(self.octave_range)
        return d

    @classmethod
    def from_dict(cls, d: dict) -> "SequenceConfig":
        d = d.copy()
        if "octave_range" in d:
            d["octave_range"] = tuple(d["octave_range"])
        return cls(**d)

    @classmethod
    def random(cls) -> "SequenceConfig":
        return cls(
            key=random.choice(list(KEY_OFFSETS.keys())),
            scale=random.choice(list(SCALE_INTERVALS.keys())),
            tempo=random.randint(60, 180),
            time_signature_num=random.choice([3, 4, 4, 4, 6]),
            time_signature_den=4,
            num_bars=random.choice([4, 4, 8, 8, 8, 12, 16]),
            octave_range=(random.choice([3, 4]), random.choice([5, 6])),
            rhythm_pattern=random.choice(list(RHYTHM_PATTERNS.keys())),
            note_duration_variety=random.choice(["low", "medium", "high"]),
            rest_probability=round(random.uniform(0.05, 0.25), 2),
            velocity_variation=random.choice([True, False]),
            instrument=random.choice([0, 4, 12, 19, 24, 25, 40, 48, 73]),
        )


# ─────────────────────────────────────────────
# Duration Variety Profiles
# ─────────────────────────────────────────────

DURATION_PROFILES = {
    "low": {
        "quarter": 0.7, "half": 0.2, "eighth": 0.1
    },
    "medium": {
        "quarter": 0.4, "half": 0.15, "eighth": 0.25,
        "dotted_quarter": 0.1, "sixteenth": 0.1
    },
    "high": {
        "quarter": 0.2, "half": 0.1, "eighth": 0.2,
        "sixteenth": 0.2, "dotted_quarter": 0.15,
        "dotted_eighth": 0.1, "whole": 0.05
    },
}


# ─────────────────────────────────────────────
# Generator
# ─────────────────────────────────────────────

class MidiSequenceGenerator:
    def __init__(self, config: Optional[SequenceConfig] = None):
        self.config = config or SequenceConfig()

    def _get_scale_notes(self) -> list[int]:
        root = KEY_OFFSETS[self.config.key]
        intervals = SCALE_INTERVALS[self.config.scale]
        notes = []
        lo, hi = self.config.octave_range
        for octave in range(lo, hi + 1):
            for interval in intervals:
                midi_note = (octave + 1) * 12 + root + interval
                if 21 <= midi_note <= 108:
                    notes.append(midi_note)
        return sorted(notes)

    def _pick_duration(self) -> float:
        profile = DURATION_PROFILES.get(self.config.note_duration_variety, DURATION_PROFILES["medium"])
        names = list(profile.keys())
        weights = list(profile.values())
        chosen = random.choices(names, weights=weights, k=1)[0]
        return NOTE_DURATIONS[chosen]

    def _get_rhythm_pattern(self) -> list[float]:
        pattern_key = self.config.rhythm_pattern
        if pattern_key == "mixed":
            return random.choice([v for k, v in RHYTHM_PATTERNS.items() if v is not None])
        return RHYTHM_PATTERNS.get(pattern_key, RHYTHM_PATTERNS["straight"])

    def _velocity(self) -> int:
        if self.config.velocity_variation:
            return random.randint(55, 110)
        return 80

    def generate(self) -> tuple[pretty_midi.PrettyMIDI, dict]:
        cfg = self.config
        pm = pretty_midi.PrettyMIDI(initial_tempo=cfg.tempo)
        instrument = pretty_midi.Instrument(program=cfg.instrument)

        scale_notes = self._get_scale_notes()
        beats_per_bar = cfg.time_signature_num
        quarter_duration = 60.0 / cfg.tempo  # seconds per quarter note
        bar_duration = beats_per_bar * quarter_duration

        current_time = 0.0
        total_bars = cfg.num_bars
        note_count = 0
        pitch_histogram = [0] * 12

        for bar in range(total_bars):
            bar_start = bar * bar_duration
            bar_end = bar_start + bar_duration
            t = bar_start

            while t < bar_end - 0.01:
                remaining = bar_end - t

                # Rest?
                if random.random() < cfg.rest_probability:
                    rest_dur = min(self._pick_duration() * quarter_duration, remaining)
                    t += rest_dur
                    continue

                # Pick note
                note_midi = random.choice(scale_notes)
                dur_beats = self._pick_duration()
                dur_sec = min(dur_beats * quarter_duration, remaining)

                # Slight humanization
                start = t + random.uniform(-0.01, 0.01)
                end = start + dur_sec * random.uniform(0.85, 0.98)

                note = pretty_midi.Note(
                    velocity=self._velocity(),
                    pitch=note_midi,
                    start=max(0, start),
                    end=max(start + 0.05, end),
                )
                instrument.notes.append(note)
                pitch_histogram[note_midi % 12] += 1
                note_count += 1
                t += dur_sec

        pm.instruments.append(instrument)

        metadata = {
            "id": str(uuid.uuid4()),
            "config": cfg.to_dict(),
            "stats": {
                "note_count": note_count,
                "duration_seconds": round(total_bars * beats_per_bar * (60.0 / cfg.tempo), 2),
                "pitch_histogram": pitch_histogram,
                "scale_notes_used": scale_notes,
            }
        }

        return pm, metadata


# ─────────────────────────────────────────────
# Batch Generator
# ─────────────────────────────────────────────

def generate_batch(count: int, output_dir: str = "sequences", randomize: bool = True) -> list[dict]:
    import os
    os.makedirs(output_dir, exist_ok=True)
    results = []

    for i in range(count):
        config = SequenceConfig.random() if randomize else SequenceConfig()
        gen = MidiSequenceGenerator(config)
        pm, metadata = gen.generate()

        filename = f"{metadata['id']}.mid"
        filepath = os.path.join(output_dir, filename)
        pm.write(filepath)
        metadata["file_path"] = filepath
        metadata["filename"] = filename

        results.append(metadata)
        if (i + 1) % 10 == 0:
            print(f"Generated {i + 1}/{count} sequences...")

    # Save manifest
    manifest_path = os.path.join(output_dir, "manifest.json")
    with open(manifest_path, "w") as f:
        json.dump(results, f, indent=2)

    print(f"\n✅ Generated {count} sequences in '{output_dir}/'")
    print(f"   Manifest saved to {manifest_path}")
    return results


if __name__ == "__main__":
    # Quick test
    config = SequenceConfig(
        key="C", scale="major", tempo=120,
        num_bars=8, rhythm_pattern="straight"
    )
    gen = MidiSequenceGenerator(config)
    pm, meta = gen.generate()
    pm.write("/tmp/test_sequence.mid")
    print(json.dumps(meta, indent=2))
