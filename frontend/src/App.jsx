import { useState, useEffect, useRef, useCallback } from "react";

const API = "http://localhost:5000/api";

// ─── Star Rating Component ───────────────────────────────────────────────────

function StarRating({ value, onChange, disabled }) {
  const [hovered, setHovered] = useState(0);
  return (
    <div style={{ display: "flex", gap: 4 }}>
      {[1, 2, 3, 4, 5].map((star) => (
        <button
          key={star}
          disabled={disabled}
          onMouseEnter={() => setHovered(star)}
          onMouseLeave={() => setHovered(0)}
          onClick={() => onChange(star)}
          style={{
            background: "none",
            border: "none",
            cursor: disabled ? "default" : "pointer",
            fontSize: 28,
            color: star <= (hovered || value) ? "#f59e0b" : "#d1d5db",
            transition: "color 0.1s",
            padding: "0 2px",
          }}
          title={`Rate ${star} star${star > 1 ? "s" : ""}`}
        >
          ★
        </button>
      ))}
    </div>
  );
}


// ─── MIDI Player using Tone.js ────────────────────────────────────────────────

function useMidiPlayer() {
  const synthRef = useRef(null);
  const partRef = useRef(null);
  const [status, setStatus] = useState("idle");

  const loadAndPlay = useCallback(async (seqId) => {
    // Load Tone.js if not already loaded
    if (!window.Tone) {
      await new Promise((resolve, reject) => {
        const s = document.createElement("script");
        s.src = "https://cdnjs.cloudflare.com/ajax/libs/tone/14.8.49/Tone.js";
        s.onload = resolve;
        s.onerror = reject;
        document.head.appendChild(s);
      });
    }

    // Load @tonejs/midi
    const { Midi } = await import("@tonejs/midi");

    setStatus("loading");

    try {
      // Fetch the MIDI file
      const res = await fetch(`${API}/sequences/${seqId}/midi`);
      const arrayBuffer = await res.arrayBuffer();

      // Parse with @tonejs/midi (much more reliable than custom parser)
      const midi = new Midi(arrayBuffer);

      await window.Tone.start();

      // Clean up previous playback
      if (partRef.current) {
        partRef.current.dispose();
      }
      if (synthRef.current) {
        synthRef.current.dispose();
      }

      window.Tone.Transport.cancel();
      window.Tone.Transport.stop();

      // Create synth
      const synth = new window.Tone.PolySynth(window.Tone.Synth, {
        oscillator: { type: "triangle" },
        envelope: { attack: 0.02, decay: 0.1, sustain: 0.5, release: 0.8 },
        volume: -6,
      }).toDestination();
      synthRef.current = synth;

      // Build note events from all tracks
      const notes = [];
      midi.tracks.forEach((track) => {
        track.notes.forEach((note) => {
          notes.push({
            time: note.time,
            note: note.name,
            duration: Math.max(0.05, note.duration),
            velocity: note.velocity,
          });
        });
      });

      if (notes.length === 0) {
        console.warn("No notes found in MIDI file");
        setStatus("idle");
        return;
      }

      console.log(`Playing ${notes.length} notes`);

      // Schedule all notes
      const part = new window.Tone.Part((time, ev) => {
        synth.triggerAttackRelease(
          ev.note,
          ev.duration,
          time,
          ev.velocity
        );
      }, notes);

      part.start(0);
      partRef.current = part;

      // Start transport
      window.Tone.Transport.start();
      setStatus("playing");

      // Schedule end
      const lastNote = Math.max(...notes.map((n) => n.time + n.duration));
      window.Tone.Transport.scheduleOnce(() => {
        setStatus("done");
      }, lastNote + 0.5);

    } catch (err) {
      console.error("MIDI playback error:", err);
      setStatus("idle");
    }
  }, []);

  const stop = useCallback(() => {
    if (window.Tone) {
      window.Tone.Transport.stop();
      window.Tone.Transport.cancel();
    }
    if (partRef.current) {
      partRef.current.stop();
      partRef.current.dispose();
      partRef.current = null;
    }
    if (synthRef.current) {
      synthRef.current.dispose();
      synthRef.current = null;
    }
    setStatus("idle");
  }, []);

  return { loadAndPlay, stop, status };
}


// ─── Sequence Card ────────────────────────────────────────────────────────────

function SequenceCard({ seq, onRated }) {
  const { loadAndPlay, stop, status } = useMidiPlayer();
  const [rating, setRating] = useState(seq.avg_rating ? Math.round(seq.avg_rating) : 0);
  const [submitting, setSubmitting] = useState(false);
  const [submitted, setSubmitted] = useState(seq.rating_count > 0);
  const playStart = useRef(null);

  const handlePlay = () => {
    if (status === "playing") { stop(); return; }
    playStart.current = Date.now();
    loadAndPlay(seq.id);
  };

  const handleRate = async (stars) => {
    setRating(stars);
    setSubmitting(true);
    const listenDur = playStart.current ? (Date.now() - playStart.current) / 1000 : null;
    stop();
    await fetch(`${API}/sequences/${seq.id}/rate`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ rating: stars, listen_duration: listenDur }),
    });
    setSubmitting(false);
    setSubmitted(true);
    onRated?.();
  };

  const statusIcon = { idle: "▶", loading: "…", playing: "⏹", paused: "▶", done: "↺" }[status];

  return (
    <div style={{
      background: submitted ? "#f0fdf4" : "white",
      border: `2px solid ${submitted ? "#86efac" : "#e5e7eb"}`,
      borderRadius: 12,
      padding: "16px 20px",
      display: "flex",
      flexDirection: "column",
      gap: 10,
      boxShadow: "0 1px 4px rgba(0,0,0,0.06)",
      transition: "border-color 0.2s",
    }}>
      {/* Header */}
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start" }}>
        <div>
          <div style={{ fontWeight: 700, fontSize: 15, color: "#111" }}>
            {seq.key_signature} {seq.scale}
          </div>
          <div style={{ fontSize: 12, color: "#6b7280", marginTop: 2 }}>
            {seq.tempo} BPM · {seq.num_bars} bars · {seq.rhythm_pattern}
          </div>
        </div>
        <div style={{ fontSize: 11, color: "#9ca3af", textAlign: "right" }}>
          {seq.note_count} notes<br />
          {seq.duration_seconds}s
        </div>
      </div>

      {/* Play button */}
      <button
        onClick={handlePlay}
        style={{
          background: status === "playing" ? "#ef4444" : "#3b82f6",
          color: "white",
          border: "none",
          borderRadius: 8,
          padding: "8px 0",
          cursor: "pointer",
          fontWeight: 600,
          fontSize: 14,
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          gap: 6,
          transition: "background 0.15s",
        }}
      >
        {statusIcon} {status === "playing" ? "Stop" : status === "loading" ? "Loading…" : "Play"}
      </button>

      {/* Rating */}
      <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between" }}>
        <StarRating value={rating} onChange={handleRate} disabled={submitting} />
        {submitted && <span style={{ fontSize: 12, color: "#16a34a", fontWeight: 600 }}>✓ Rated</span>}
        {submitting && <span style={{ fontSize: 12, color: "#9ca3af" }}>Saving…</span>}
      </div>
    </div>
  );
}


// ─── Stats Panel ──────────────────────────────────────────────────────────────

function StatsPanel({ stats, onGenerate }) {
  const progress = stats ? Math.round((stats.rated_sequences / 500) * 100) : 0;

  return (
    <div style={{
      background: "white", borderRadius: 12, padding: 20,
      border: "1px solid #e5e7eb", boxShadow: "0 1px 4px rgba(0,0,0,0.06)"
    }}>
      <h2 style={{ margin: "0 0 12px", fontSize: 16, fontWeight: 700, color: "#111" }}>
        📊 Progress
      </h2>
      {stats ? (
        <>
          <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 10, marginBottom: 14 }}>
            {[
              ["Total Sequences", stats.total_sequences],
              ["Rated", stats.rated_sequences],
              ["Unrated", stats.unrated_sequences],
              ["Target", "500"],
            ].map(([label, val]) => (
              <div key={label} style={{ background: "#f9fafb", borderRadius: 8, padding: "8px 12px" }}>
                <div style={{ fontSize: 20, fontWeight: 800, color: "#1d4ed8" }}>{val}</div>
                <div style={{ fontSize: 12, color: "#6b7280" }}>{label}</div>
              </div>
            ))}
          </div>

          {/* Progress bar */}
          <div style={{ fontSize: 12, color: "#6b7280", marginBottom: 4 }}>
            Rating Progress: {progress}%
          </div>
          <div style={{ background: "#e5e7eb", borderRadius: 99, height: 8, overflow: "hidden" }}>
            <div style={{
              background: "linear-gradient(90deg, #3b82f6, #8b5cf6)",
              width: `${Math.min(progress, 100)}%`,
              height: "100%",
              borderRadius: 99,
              transition: "width 0.4s ease",
            }} />
          </div>

          {/* Rating distribution */}
          <div style={{ marginTop: 14 }}>
            <div style={{ fontSize: 13, fontWeight: 600, marginBottom: 6, color: "#374151" }}>Rating Distribution</div>
            {[1, 2, 3, 4, 5].map((star) => {
              const count = stats.rating_distribution?.[star] || 0;
              const total = stats.rated_sequences || 1;
              const pct = Math.round((count / total) * 100);
              return (
                <div key={star} style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 4 }}>
                  <span style={{ fontSize: 13, color: "#f59e0b", width: 20 }}>{"★".repeat(star)}</span>
                  <div style={{ flex: 1, background: "#f3f4f6", borderRadius: 99, height: 6 }}>
                    <div style={{ background: "#f59e0b", width: `${pct}%`, height: "100%", borderRadius: 99 }} />
                  </div>
                  <span style={{ fontSize: 12, color: "#6b7280", width: 30, textAlign: "right" }}>{count}</span>
                </div>
              );
            })}
          </div>
        </>
      ) : (
        <div style={{ color: "#9ca3af", fontSize: 13 }}>Loading stats…</div>
      )}

      {/* Generate buttons */}
      <div style={{ display: "flex", gap: 8, marginTop: 16 }}>
        <button onClick={() => onGenerate(10)} style={btnStyle("#3b82f6")}>+ 10 Sequences</button>
        <button onClick={() => onGenerate(50)} style={btnStyle("#8b5cf6")}>+ 50 Sequences</button>
      </div>
    </div>
  );
}

const btnStyle = (color) => ({
  flex: 1, background: color, color: "white", border: "none",
  borderRadius: 8, padding: "9px 0", cursor: "pointer",
  fontWeight: 600, fontSize: 13,
});


// ─── Main App ─────────────────────────────────────────────────────────────────

export default function App() {
  const [sequences, setSequences] = useState([]);
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(false);
  const [filter, setFilter] = useState("unrated"); // unrated | all

  const fetchStats = async () => {
    const res = await fetch(`${API}/stats`);
    setStats(await res.json());
  };

  const fetchSequences = useCallback(async () => {
    setLoading(true);
    const unratedFirst = filter === "unrated";
    const res = await fetch(`${API}/sequences?per_page=12&unrated_first=${unratedFirst}`);
    const data = await res.json();
    setSequences(data.sequences || []);
    setLoading(false);
  }, [filter]);

  useEffect(() => { fetchStats(); }, []);
  useEffect(() => { fetchSequences(); }, [fetchSequences]);

  const handleGenerate = async (count) => {
    setLoading(true);
    await fetch(`${API}/sequences/batch`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ count }),
    });
    await Promise.all([fetchStats(), fetchSequences()]);
  };

  const handleRated = () => {
    fetchStats();
    // Optionally refresh to surface new unrated sequences
    setTimeout(fetchSequences, 800);
  };

  return (
    <div style={{
      minHeight: "100vh",
      background: "linear-gradient(135deg, #eff6ff 0%, #faf5ff 100%)",
      fontFamily: "'Inter', system-ui, sans-serif",
      padding: "24px 16px",
    }}>
      <div style={{ maxWidth: 1100, margin: "0 auto" }}>

        {/* Header */}
        <div style={{ textAlign: "center", marginBottom: 32 }}>
          <h1 style={{ margin: 0, fontSize: 32, fontWeight: 900, color: "#1e1b4b",
            background: "linear-gradient(90deg, #3b82f6, #8b5cf6)", WebkitBackgroundClip: "text",
            WebkitTextFillColor: "transparent" }}>
            🎵 MusicGen Studio
          </h1>
          <p style={{ color: "#6b7280", marginTop: 6, fontSize: 15 }}>
            Listen, rate sequences — building your personalized music dataset
          </p>
        </div>

        <div style={{ display: "grid", gridTemplateColumns: "280px 1fr", gap: 24, alignItems: "start" }}>

          {/* Sidebar */}
          <div style={{ display: "flex", flexDirection: "column", gap: 16 }}>
            <StatsPanel stats={stats} onGenerate={handleGenerate} />

            {/* Filter */}
            <div style={{ background: "white", borderRadius: 12, padding: 16,
              border: "1px solid #e5e7eb", boxShadow: "0 1px 4px rgba(0,0,0,0.06)" }}>
              <div style={{ fontSize: 14, fontWeight: 600, marginBottom: 10, color: "#374151" }}>Filter</div>
              {["unrated", "all"].map((f) => (
                <button key={f} onClick={() => setFilter(f)} style={{
                  display: "block", width: "100%", textAlign: "left",
                  background: filter === f ? "#eff6ff" : "none",
                  border: `1px solid ${filter === f ? "#93c5fd" : "#e5e7eb"}`,
                  borderRadius: 7, padding: "7px 12px", cursor: "pointer",
                  color: filter === f ? "#1d4ed8" : "#374151",
                  fontWeight: filter === f ? 600 : 400,
                  marginBottom: 6, fontSize: 13,
                }}>
                  {f === "unrated" ? "🆕 Unrated First" : "📋 All Sequences"}
                </button>
              ))}
            </div>
          </div>

          {/* Grid */}
          <div>
            {loading ? (
              <div style={{ textAlign: "center", padding: 60, color: "#9ca3af" }}>Loading sequences…</div>
            ) : sequences.length === 0 ? (
              <div style={{ textAlign: "center", padding: 60 }}>
                <div style={{ fontSize: 48 }}>🎼</div>
                <div style={{ color: "#6b7280", marginTop: 12 }}>No sequences yet. Generate some!</div>
              </div>
            ) : (
              <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(280px, 1fr))", gap: 16 }}>
                {sequences.map((seq) => (
                  <SequenceCard key={seq.id} seq={seq} onRated={handleRated} />
                ))}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
