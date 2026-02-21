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
  const toneRef = useRef(null);
  const partRef = useRef(null);
  const [status, setStatus] = useState("idle"); // idle | loading | playing | paused | done

  const loadAndPlay = useCallback(async (seqId, onTimeUpdate) => {
    // Dynamically load Tone.js from CDN
    if (!window.Tone) {
      await new Promise((resolve, reject) => {
        const s = document.createElement("script");
        s.src = "https://cdnjs.cloudflare.com/ajax/libs/tone/14.8.49/Tone.js";
        s.onload = resolve;
        s.onerror = reject;
        document.head.appendChild(s);
      });
    }

    // Fetch MIDI binary
    setStatus("loading");
    const res = await fetch(`${API}/sequences/${seqId}/midi`);
    const buf = await res.arrayBuffer();

    // Parse MIDI manually (lightweight parser)
    const notes = parseMidi(buf);
    if (!notes.length) { setStatus("idle"); return; }

    await window.Tone.start();
    if (partRef.current) { partRef.current.dispose(); }

    const synth = new window.Tone.PolySynth(window.Tone.Synth, {
      oscillator: { type: "triangle" },
      envelope: { attack: 0.02, decay: 0.1, sustain: 0.5, release: 0.8 },
    }).toDestination();
    toneRef.current = synth;

    const events = notes.map((n) => ({
      time: n.start,
      note: window.Tone.Frequency(n.pitch, "midi").toNote(),
      duration: Math.max(0.05, n.end - n.start),
      velocity: n.velocity / 127,
    }));

    const part = new window.Tone.Part((time, ev) => {
      synth.triggerAttackRelease(ev.note, ev.duration, time, ev.velocity);
    }, events);

    part.start(0);
    partRef.current = part;

    window.Tone.Transport.cancel();
    window.Tone.Transport.start();
    setStatus("playing");

    const lastTime = Math.max(...notes.map((n) => n.end));
    window.Tone.Transport.scheduleOnce(() => {
      setStatus("done");
    }, lastTime + 0.5);
  }, []);

  const stop = useCallback(() => {
    if (window.Tone) window.Tone.Transport.stop();
    if (partRef.current) partRef.current.stop();
    setStatus("idle");
  }, []);

  return { loadAndPlay, stop, status };
}


// Minimal MIDI parser (handles Type 0 and Type 1)
function parseMidi(buffer) {
  const view = new DataView(buffer);
  const bytes = new Uint8Array(buffer);

  let pos = 0;
  function readUint32() { const v = view.getUint32(pos); pos += 4; return v; }
  function readUint16() { const v = view.getUint16(pos); pos += 2; return v; }
  function readUint8() { return bytes[pos++]; }
  function readVarLen() {
    let val = 0;
    let b;
    do { b = readUint8(); val = (val << 7) | (b & 0x7f); } while (b & 0x80);
    return val;
  }

  const magic = readUint32();
  if (magic !== 0x4d546864) return []; // Not MIDI

  const headerLen = readUint32();
  const format = readUint16();
  const numTracks = readUint16();
  const ticksPerBeat = readUint16();

  const notes = [];
  let tempo = 500000; // default 120 BPM

  for (let t = 0; t < numTracks; t++) {
    const trackMagic = readUint32();
    const trackLen = readUint32();
    const trackEnd = pos + trackLen;

    let tick = 0;
    let lastStatus = 0;
    const activeNotes = {};

    while (pos < trackEnd) {
      const delta = readVarLen();
      tick += delta;

      let statusByte = bytes[pos];
      if (statusByte & 0x80) { lastStatus = statusByte; pos++; }
      else { statusByte = lastStatus; }

      const type = statusByte >> 4;
      const ch = statusByte & 0x0f;

      if (statusByte === 0xff) {
        const metaType = readUint8();
        const metaLen = readVarLen();
        if (metaType === 0x51 && metaLen === 3) {
          tempo = (bytes[pos] << 16) | (bytes[pos + 1] << 8) | bytes[pos + 2];
        }
        pos += metaLen;
      } else if (type === 9) {
        const pitch = readUint8();
        const vel = readUint8();
        const timeSec = (tick / ticksPerBeat) * (tempo / 1e6);
        if (vel > 0) {
          activeNotes[pitch] = { pitch, start: timeSec, velocity: vel };
        } else if (activeNotes[pitch]) {
          const n = activeNotes[pitch];
          notes.push({ ...n, end: timeSec });
          delete activeNotes[pitch];
        }
      } else if (type === 8) {
        const pitch = readUint8(); readUint8();
        const timeSec = (tick / ticksPerBeat) * (tempo / 1e6);
        if (activeNotes[pitch]) {
          notes.push({ ...activeNotes[pitch], end: timeSec });
          delete activeNotes[pitch];
        }
      } else if (type === 0xa || type === 0xb || type === 0xe) {
        readUint8(); readUint8();
      } else if (type === 0xc || type === 0xd) {
        readUint8();
      } else {
        break;
      }
    }
    pos = trackEnd;
  }

  return notes.sort((a, b) => a.start - b.start);
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
