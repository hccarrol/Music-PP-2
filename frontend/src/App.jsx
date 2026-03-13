import { useState, useEffect, useRef, useCallback } from "react";

const API = "http://localhost:5000/api";
const PER_PAGE = 12;

// ─── Global Audio Manager ─────────────────────────────────────────────────────
const audioManager = {
  currentStop: null,
  stopCurrent() {
    if (this.currentStop) {
      this.currentStop();
      this.currentStop = null;
    }
  },
  register(stopFn) {
    this.stopCurrent();
    this.currentStop = stopFn;
  },
};

// ─── Tone.js Loader ───────────────────────────────────────────────────────────
let toneLoaded = false;
async function ensureTone() {
  if (toneLoaded && window.Tone) return;
  await new Promise((resolve, reject) => {
    const s = document.createElement("script");
    s.src = "https://cdnjs.cloudflare.com/ajax/libs/tone/14.8.49/Tone.js";
    s.onload = () => { toneLoaded = true; resolve(); };
    s.onerror = reject;
    document.head.appendChild(s);
  });
}

// ─── API Helpers ──────────────────────────────────────────────────────────────
async function apiFetch(url, options) {
  const res = await fetch(url, options);
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  return res.json();
}

// ─── Star Rating ──────────────────────────────────────────────────────────────
function StarRating({ value, onChange, disabled }) {
  const [hovered, setHovered] = useState(0);
  return (
    <div style={{ display: "flex", gap: 4 }}>
      {[1, 2, 3, 4, 5].map((star) => (
        <button
          key={star}
          disabled={disabled}
          onMouseEnter={() => !disabled && setHovered(star)}
          onMouseLeave={() => setHovered(0)}
          onClick={() => !disabled && onChange(star)}
          style={{
            background: "none", border: "none",
            cursor: disabled ? "default" : "pointer",
            fontSize: 26,
            color: star <= (hovered || value) ? "#f59e0b" : "#d1d5db",
            transition: "color 0.1s", padding: "0 1px",
          }}
        >★</button>
      ))}
    </div>
  );
}

// ─── Sequence Card ────────────────────────────────────────────────────────────
function SequenceCard({ seq: initialSeq, onRated }) {
  // Keep local copy of seq so rating updates immediately
  const [seq, setSeq] = useState(initialSeq);
  const [status, setStatus] = useState("idle");
  const [rating, setRating] = useState(
    initialSeq.avg_rating ? Math.round(initialSeq.avg_rating) : 0
  );
  const [ratingState, setRatingState] = useState(
    initialSeq.rating_count > 0 ? "done" : "idle"
  );

  const synthRef = useRef(null);
  const partRef = useRef(null);
  const playStartRef = useRef(null);

  // Sync if parent refreshes the seq data
  useEffect(() => {
    setSeq(initialSeq);
    if (initialSeq.rating_count > 0 && ratingState === "idle") {
      setRatingState("done");
      setRating(Math.round(initialSeq.avg_rating));
    }
  }, [initialSeq.id]);

  const cleanup = useCallback(() => {
    try {
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
    } catch (e) { /* ignore */ }
    setStatus("idle");
  }, []);

  const handlePlay = async () => {
    if (status === "playing") {
      audioManager.stopCurrent();
      return;
    }
    audioManager.stopCurrent();
    audioManager.register(cleanup);
    setStatus("loading");
    playStartRef.current = Date.now();

    try {
      const { Midi } = await import("@tonejs/midi");
      await ensureTone();
      await window.Tone.start();

      const res = await fetch(`${API}/sequences/${seq.id}/midi`);
      if (!res.ok) throw new Error("Failed to fetch MIDI");
      const arrayBuffer = await res.arrayBuffer();
      const midi = new Midi(arrayBuffer);

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

      if (!notes.length) { setStatus("idle"); return; }

      const synth = new window.Tone.PolySynth(window.Tone.Synth, {
        oscillator: { type: "triangle" },
        envelope: { attack: 0.02, decay: 0.1, sustain: 0.5, release: 0.8 },
        volume: -6,
      }).toDestination();
      synthRef.current = synth;

      window.Tone.Transport.cancel();
      window.Tone.Transport.stop();

      const part = new window.Tone.Part((time, ev) => {
        try {
          synth.triggerAttackRelease(ev.note, ev.duration, time, ev.velocity);
        } catch (e) { /* ignore */ }
      }, notes);

      part.start(0);
      partRef.current = part;
      window.Tone.Transport.start();
      setStatus("playing");

      const lastNote = Math.max(...notes.map((n) => n.time + n.duration));
      window.Tone.Transport.scheduleOnce(() => {
        setStatus("done");
        audioManager.currentStop = null;
      }, lastNote + 0.5);

    } catch (err) {
      console.error("Playback error:", err);
      cleanup();
    }
  };

  const handleRate = async (stars) => {
    if (ratingState === "saving") return;
    // Update UI immediately — don't wait for server
    setRating(stars);
    setRatingState("saving");
    audioManager.stopCurrent();

    const listenDur = playStartRef.current
      ? (Date.now() - playStartRef.current) / 1000
      : null;

    try {
      await apiFetch(`${API}/sequences/${seq.id}/rate`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ rating: stars, listen_duration: listenDur }),
      });
      // Update local state immediately
      setRatingState("done");
      setSeq((prev) => ({ ...prev, rating_count: (prev.rating_count || 0) + 1, avg_rating: stars }));
      onRated?.();
    } catch (err) {
      console.error("Rating error:", err);
      setRatingState("error");
      setTimeout(() => setRatingState("idle"), 2000);
    }
  };

  const btnLabel = {
    idle: "▶ Play", loading: "… Loading",
    playing: "⏹ Stop", done: "↺ Replay",
  }[status];

  const ratingLabel = {
    idle: null,
    saving: <span style={{ fontSize: 12, color: "#9ca3af" }}>Saving…</span>,
    done: <span style={{ fontSize: 12, color: "#16a34a", fontWeight: 600 }}>✓ Rated</span>,
    error: <span style={{ fontSize: 12, color: "#ef4444" }}>Failed — try again</span>,
  }[ratingState];

  return (
    <div style={{
      background: ratingState === "done" ? "#f0fdf4" : "white",
      border: `2px solid ${ratingState === "done" ? "#86efac" : "#e5e7eb"}`,
      borderRadius: 12, padding: "16px 20px",
      display: "flex", flexDirection: "column", gap: 10,
      boxShadow: "0 1px 4px rgba(0,0,0,0.06)",
      transition: "border-color 0.2s, background 0.2s",
    }}>
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
          {seq.note_count} notes<br />{seq.duration_seconds}s
        </div>
      </div>

      <button onClick={handlePlay} style={{
        background: status === "playing" ? "#ef4444" : "#3b82f6",
        color: "white", border: "none", borderRadius: 8,
        padding: "8px 0", cursor: "pointer", fontWeight: 600,
        fontSize: 14, transition: "background 0.15s",
      }}>
        {btnLabel}
      </button>

      <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between" }}>
        <StarRating value={rating} onChange={handleRate} disabled={ratingState === "saving"} />
        {ratingLabel}
      </div>
    </div>
  );
}

// ─── Stats Panel ──────────────────────────────────────────────────────────────
function StatsPanel({ stats, onGenerate, generating }) {
  const progress = stats
    ? Math.min(Math.round((stats.rated_sequences / 500) * 100), 100)
    : 0;

  return (
    <div style={{
      background: "white", borderRadius: 12, padding: 20,
      border: "1px solid #e5e7eb", boxShadow: "0 1px 4px rgba(0,0,0,0.06)",
    }}>
      <h2 style={{ margin: "0 0 12px", fontSize: 16, fontWeight: 700 }}>📊 Progress</h2>
      {stats ? (
        <>
          <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 10, marginBottom: 14 }}>
            {[["Total", stats.total_sequences], ["Rated", stats.rated_sequences],
              ["Unrated", stats.unrated_sequences], ["Goal", "500"]].map(([label, val]) => (
              <div key={label} style={{ background: "#f9fafb", borderRadius: 8, padding: "8px 12px" }}>
                <div style={{ fontSize: 20, fontWeight: 800, color: "#1d4ed8" }}>{val}</div>
                <div style={{ fontSize: 12, color: "#6b7280" }}>{label}</div>
              </div>
            ))}
          </div>

          <div style={{ fontSize: 12, color: "#6b7280", marginBottom: 4 }}>Progress: {progress}%</div>
          <div style={{ background: "#e5e7eb", borderRadius: 99, height: 8, overflow: "hidden" }}>
            <div style={{
              background: "linear-gradient(90deg, #3b82f6, #8b5cf6)",
              width: `${progress}%`, height: "100%", borderRadius: 99,
              transition: "width 0.4s ease",
            }} />
          </div>

          <div style={{ marginTop: 14 }}>
            <div style={{ fontSize: 13, fontWeight: 600, marginBottom: 6, color: "#374151" }}>
              Rating Distribution
            </div>
            {[1, 2, 3, 4, 5].map((star) => {
              const count = stats.rating_distribution?.[star] || 0;
              const pct = Math.round((count / Math.max(stats.rated_sequences, 1)) * 100);
              return (
                <div key={star} style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 4 }}>
                  <span style={{ fontSize: 12, color: "#f59e0b", width: 20 }}>{"★".repeat(star)}</span>
                  <div style={{ flex: 1, background: "#f3f4f6", borderRadius: 99, height: 6 }}>
                    <div style={{ background: "#f59e0b", width: `${pct}%`, height: "100%", borderRadius: 99 }} />
                  </div>
                  <span style={{ fontSize: 12, color: "#6b7280", width: 24, textAlign: "right" }}>{count}</span>
                </div>
              );
            })}
          </div>
        </>
      ) : (
        <div style={{ color: "#9ca3af", fontSize: 13 }}>Loading stats…</div>
      )}

      <div style={{ display: "flex", gap: 8, marginTop: 16 }}>
        {[10, 50].map((n) => (
          <button key={n} onClick={() => onGenerate(n)} disabled={generating}
            style={{
              flex: 1, background: generating ? "#9ca3af" : n === 10 ? "#3b82f6" : "#8b5cf6",
              color: "white", border: "none", borderRadius: 8, padding: "9px 0",
              cursor: generating ? "not-allowed" : "pointer", fontWeight: 600, fontSize: 13,
            }}>
            {generating ? "Generating…" : `+ ${n}`}
          </button>
        ))}
      </div>
    </div>
  );
}

// ─── Pagination ───────────────────────────────────────────────────────────────
function Pagination({ page, totalPages, total, onChange }) {
  if (totalPages <= 1) return null;
  return (
    <div style={{ display: "flex", justifyContent: "center", alignItems: "center", gap: 12, marginTop: 24 }}>
      <button onClick={() => onChange(page - 1)} disabled={page === 1}
        style={{
          background: page === 1 ? "#e5e7eb" : "#3b82f6", color: page === 1 ? "#9ca3af" : "white",
          border: "none", borderRadius: 8, padding: "8px 16px",
          cursor: page === 1 ? "not-allowed" : "pointer", fontWeight: 600,
        }}>← Prev</button>
      <span style={{ fontSize: 14, color: "#6b7280" }}>
        Page {page} of {totalPages} ({total} total)
      </span>
      <button onClick={() => onChange(page + 1)} disabled={page === totalPages}
        style={{
          background: page === totalPages ? "#e5e7eb" : "#3b82f6",
          color: page === totalPages ? "#9ca3af" : "white",
          border: "none", borderRadius: 8, padding: "8px 16px",
          cursor: page === totalPages ? "not-allowed" : "pointer", fontWeight: 600,
        }}>Next →</button>
    </div>
  );
}

// ─── Main App ─────────────────────────────────────────────────────────────────
export default function App() {
  const [sequences, setSequences] = useState([]);
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(false);
  const [generating, setGenerating] = useState(false);
  const [filter, setFilter] = useState("unrated");
  const [page, setPage] = useState(1);
  const [total, setTotal] = useState(0);

  // Use a refresh counter to force re-fetch without changing other deps
  const [refreshKey, setRefreshKey] = useState(0);
  const refresh = useCallback(() => setRefreshKey((k) => k + 1), []);

  const fetchStats = useCallback(async () => {
    try {
      const data = await apiFetch(`${API}/stats`);
      setStats(data);
    } catch (e) { console.error("Stats error:", e); }
  }, []);

  const fetchSequences = useCallback(async (targetPage, targetFilter) => {
    setLoading(true);
    try {
      const unratedFirst = targetFilter === "unrated";
      // For unrated tab: only show sequences with no ratings
      // For all tab: show everything sorted by newest first
      const url = unratedFirst
        ? `${API}/sequences?per_page=${PER_PAGE}&page=${targetPage}&unrated_first=true`
        : `${API}/sequences?per_page=${PER_PAGE}&page=${targetPage}&unrated_first=false`;

      const data = await apiFetch(url);
      setSequences(data.sequences || []);
      setTotal(data.total || 0);
    } catch (e) {
      console.error("Sequences error:", e);
      setSequences([]);
    }
    setLoading(false);
  }, []);

  // Fetch on mount immediately
  useEffect(() => {
    fetchStats();
    fetchSequences(1, "unrated");
  }, []);

  // Refetch when filter, page, or refreshKey changes
  useEffect(() => {
    fetchStats();
    fetchSequences(page, filter);
  }, [filter, page, refreshKey]);

  const handleFilterChange = (newFilter) => {
    if (newFilter === filter) return;
    setFilter(newFilter);
    setPage(1); // Reset to page 1 on filter change
  };

  const handlePageChange = (newPage) => {
    setPage(newPage);
    window.scrollTo({ top: 0, behavior: "smooth" });
  };

  const handleGenerate = async (count) => {
    setGenerating(true);
    try {
      await apiFetch(`${API}/sequences/batch`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ count }),
      });
      setPage(1);
      refresh(); // Force immediate refetch
    } catch (e) {
      console.error("Generate error:", e);
    }
    setGenerating(false);
  };

  const handleRated = useCallback(() => {
    // Refresh data after a short delay to let DB write complete
    setTimeout(refresh, 300);
  }, [refresh]);

  const totalPages = Math.ceil(total / PER_PAGE);

  // Filter sequences client-side for unrated tab as extra guarantee
  const displayedSequences = filter === "unrated"
    ? sequences.filter((s) => !s.rating_count || s.rating_count === 0)
    : sequences;

  return (
    <div style={{
      minHeight: "100vh",
      background: "linear-gradient(135deg, #eff6ff 0%, #faf5ff 100%)",
      fontFamily: "'Inter', system-ui, sans-serif",
      padding: "24px 16px",
    }}>
      <div style={{ maxWidth: 1100, margin: "0 auto" }}>
        <div style={{ textAlign: "center", marginBottom: 32 }}>
          <h1 style={{
            margin: 0, fontSize: 32, fontWeight: 900,
            background: "linear-gradient(90deg, #3b82f6, #8b5cf6)",
            WebkitBackgroundClip: "text", WebkitTextFillColor: "transparent",
          }}>🎵 MusicGen Studio</h1>
          <p style={{ color: "#6b7280", marginTop: 6, fontSize: 15 }}>
            Listen, rate sequences — building your personalized music dataset
          </p>
        </div>

        <div style={{ display: "grid", gridTemplateColumns: "280px 1fr", gap: 24, alignItems: "start" }}>

          {/* Sidebar */}
          <div style={{ display: "flex", flexDirection: "column", gap: 16 }}>
            <StatsPanel stats={stats} onGenerate={handleGenerate} generating={generating} />

            <div style={{
              background: "white", borderRadius: 12, padding: 16,
              border: "1px solid #e5e7eb", boxShadow: "0 1px 4px rgba(0,0,0,0.06)",
            }}>
              <div style={{ fontSize: 14, fontWeight: 600, marginBottom: 10, color: "#374151" }}>
                View
              </div>
              {[
                { key: "unrated", label: "🆕 Unrated First" },
                { key: "all", label: "📋 All Sequences" },
              ].map(({ key, label }) => (
                <button key={key} onClick={() => handleFilterChange(key)} style={{
                  display: "block", width: "100%", textAlign: "left",
                  background: filter === key ? "#eff6ff" : "none",
                  border: `1px solid ${filter === key ? "#93c5fd" : "#e5e7eb"}`,
                  borderRadius: 7, padding: "7px 12px", cursor: "pointer",
                  color: filter === key ? "#1d4ed8" : "#374151",
                  fontWeight: filter === key ? 600 : 400,
                  marginBottom: 6, fontSize: 13,
                }}>{label}</button>
              ))}
            </div>
          </div>

          {/* Sequence Grid */}
          <div>
            {loading ? (
              <div style={{ textAlign: "center", padding: 60, color: "#9ca3af", fontSize: 16 }}>
                Loading sequences…
              </div>
            ) : displayedSequences.length === 0 ? (
              <div style={{ textAlign: "center", padding: 60 }}>
                <div style={{ fontSize: 48 }}>🎼</div>
                <div style={{ color: "#6b7280", marginTop: 12, fontSize: 15 }}>
                  {filter === "unrated"
                    ? "All sequences have been rated! Generate more or switch to All Sequences."
                    : "No sequences yet — use the buttons on the left to generate some."}
                </div>
              </div>
            ) : (
              <>
                {/* Tab label */}
                <div style={{
                  fontSize: 13, color: "#6b7280", marginBottom: 12, fontWeight: 500
                }}>
                  {filter === "unrated"
                    ? `Showing ${displayedSequences.length} unrated sequence${displayedSequences.length !== 1 ? "s" : ""}`
                    : `Showing ${sequences.length} of ${total} sequences`}
                </div>

                <div style={{
                  display: "grid",
                  gridTemplateColumns: "repeat(auto-fill, minmax(280px, 1fr))",
                  gap: 16,
                }}>
                  {displayedSequences.map((seq) => (
                    <SequenceCard key={seq.id} seq={seq} onRated={handleRated} />
                  ))}
                </div>

                <Pagination
                  page={page}
                  totalPages={totalPages}
                  total={total}
                  onChange={handlePageChange}
                />
              </>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}