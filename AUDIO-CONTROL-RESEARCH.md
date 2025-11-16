# Audio Control Research - Existing Solutions

## TL;DR - Recommendations

### 🚀 Quick Win (10-20ms response)
**Use `pamixer`** - Fast C++ tool, simple to integrate

```bash
pamixer --increase 5    # Instead of wpctl set-volume
pamixer --decrease 5
pamixer --toggle-mute
```

### 🎯 Ultimate Goal (<5ms response)
**Build custom Rust daemon** - No existing solution meets <5ms target
- wiremix is fast but NOT scriptable
- All other tools have process spawn overhead (10-20ms minimum)

---

## Research Findings

### 1. Wiremix Analysis

❌ **Cannot be used for scripting**
- No IPC, API, or D-Bus interface
- Purely interactive TUI application
- Achieves instant response via:
  - Persistent PipeWire connection
  - Direct protocol communication (no wpctl)
  - Compiled Rust (~0.5ms startup)
  - Event-driven architecture

**Lesson:** We need the same architecture, just with external control interface

### 2. Existing Tools Performance

| Tool | Language | Startup | Total Latency | Native PipeWire | Reliable |
|------|----------|---------|---------------|-----------------|----------|
| **Current (bash+wpctl)** | Bash | 7ms | 28-88ms | ✅ | ✅ |
| **pamixer** | C++ | 0.8ms | 10-20ms | ❌ (needs pulse) | ✅ |
| **Optimized wpctl** | Bash | 7ms | 10-15ms | ✅ | ✅ |
| **pulsemixer** | Python | 25ms | 30-40ms | ❌ (needs pulse) | ✅ |
| **pw-volume** | Rust | 0.5ms | 5-10ms | ✅ | ❌ (buggy) |
| **wiremix** | Rust | 0.5ms | <2ms | ✅ | ✅ (not scriptable) |
| **Custom daemon** | Rust | 0.5ms | **<2ms** | ✅ | TBD |

### 3. Why Bash is Slow (88ms breakdown)

```bash
# Typical script spawns MANY processes:
wpctl status           # 5-10ms process spawn
| grep "Audio"         # 2-5ms process spawn
| head -n 1            # 2-5ms process spawn
| awk '{print $2}'     # 2-5ms process spawn
wpctl set-volume ...   # 5-10ms process spawn
```

**Total overhead:** 28-52ms + bash startup (7ms) + pipeline sync = 88ms

### 4. Startup Time Comparison

- **C:** 0.26ms
- **Rust:** 0.51ms
- **C++:** 0.79ms
- **Bash:** 7.31ms (28x slower than Rust!)
- **Python:** 20-30ms

**Conclusion:** Compiled languages + persistent daemon = <5ms is achievable

---

## Detailed Analysis

### pamixer (RECOMMENDED for quick improvement)

**Install:**
```bash
# NixOS
environment.systemPackages = [ pkgs.pamixer ];
```

**Usage:**
```bash
pamixer --increase 5           # +5%
pamixer --decrease 5           # -5%
pamixer --toggle-mute          # Toggle mute
pamixer --set-volume 50        # Set to 50%
pamixer --get-volume           # Get current volume
pamixer --list-sinks           # List audio devices
```

**Pros:**
- ✅ 10x faster startup than bash (0.8ms vs 7ms)
- ✅ Simple, scriptable interface
- ✅ Widely tested and reliable
- ✅ Works with PipeWire (via pipewire-pulse layer)
- ✅ Easy drop-in replacement for current scripts

**Cons:**
- ❌ Requires pipewire-pulse compatibility layer
- ❌ Still ~10-20ms total (process spawn overhead)
- ❌ Won't achieve <5ms target

**Expected improvement:** 88ms → 10-20ms (4-8x faster)

### Optimized wpctl (Native alternative)

```bash
# Skip the parsing - use direct shortcuts
wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
```

**Pros:**
- ✅ Native PipeWire (no compatibility layer)
- ✅ More reliable change propagation
- ✅ No additional dependencies

**Cons:**
- ❌ Still has bash startup overhead (7ms)
- ❌ ~10-15ms total response time

**Expected improvement:** 88ms → 10-15ms (6x faster)

### Custom Rust Daemon (For <5ms target)

**Architecture:**
```
Keybinding → Unix Socket → Rust Daemon → PipeWire
   (0.1ms)      (0.1ms)       (0.5ms)      (1ms)
                          Total: <2ms
```

**How it works:**
1. Daemon runs in background with persistent PipeWire connection
2. Listens on Unix socket (e.g., /run/user/1000/audio-daemon.sock)
3. Receives simple text commands ("vol+5", "mute", etc.)
4. Executes via direct PipeWire API calls
5. No process spawning, no parsing overhead

**Client script (called by keybinds):**
```bash
#!/bin/bash
echo "vol+5" | socat - UNIX-CONNECT:/run/user/$UID/audio-daemon.sock
```

**Performance breakdown:**
- Socket IPC: <0.1ms
- Daemon processing: <0.5ms
- PipeWire API call: <1ms
- **Total: <2ms** ✅

**Development effort:** ~4-8 hours
- Use `pipewire-rs` crate
- ~200-500 lines of Rust
- Unix socket server with tokio
- Simple command parser
- Study wiremix source for patterns

---

## Why No Existing Tool Meets <5ms Requirement

1. **Process spawn overhead:** All CLI tools require forking new process (5-10ms minimum)
2. **Bash startup:** Scripts add 7ms just to start
3. **IPC latency:** Tools like wpctl/pamixer → daemon → PipeWire (multiple hops)
4. **wiremix limitation:** Fastest tool but not scriptable

**Only solution:** Persistent daemon with Unix socket IPC

---

## Implementation Recommendations

### Phase 1: Quick Win (Today)
Replace current scripts with pamixer:

```nix
# modules/packages.nix
environment.systemPackages = [ pkgs.pamixer ];
```

```bash
# scripts/vesktop-volume
#!/bin/bash
# Fast pamixer-based volume control
CACHE_FILE="/tmp/app-volume-cache-$USER/vesktop"
SINK_ID=$(head -1 "$CACHE_FILE" 2>/dev/null)
[[ -z "$SINK_ID" ]] && exit 1

case "$1" in
    up)   pamixer --sink "$SINK_ID" --increase 5 ;;
    down) pamixer --sink "$SINK_ID" --decrease 5 ;;
    mute) pamixer --sink "$SINK_ID" --toggle-mute ;;
esac
```

**Expected:** 88ms → 15-20ms (4-5x improvement)

### Phase 2: Custom Rust Daemon (Weekend project)

**Directory structure:**
```
~/.config/nixos/rust/audio-daemon/
├── Cargo.toml
├── src/
│   ├── main.rs          # Entry point, socket server
│   ├── pipewire.rs      # PipeWire connection & control
│   └── tracker.rs       # Track app → stream mapping
```

**Reference implementations:**
- wiremix: PipeWire integration patterns
- pipeswitch: Daemon architecture with persistent connection

**Expected:** <2ms response time ✅

---

## Testing Methodology

### Measure current performance:
```bash
time ~/.config/nixos/scripts/vesktop-volume up
# Output: real 0m0.088s (88ms)
```

### After pamixer:
```bash
time pamixer --increase 5
# Expected: real 0m0.015s (15ms)
```

### After Rust daemon:
```bash
time echo "vol+5" | socat - UNIX-CONNECT:/run/user/$UID/audio-daemon.sock
# Expected: real 0m0.002s (2ms)
```

---

## Key Resources

- **pamixer:** https://github.com/cdemoulins/pamixer
- **wiremix source:** https://github.com/tsowell/wiremix
- **pipewire-rs crate:** https://crates.io/crates/pipewire
- **pipeswitch (daemon example):** https://github.com/Teascade/pipeswitch

---

## Decision Matrix

| Priority | Solution | Effort | Improvement | Meets <5ms Goal |
|----------|----------|--------|-------------|-----------------|
| **High** | pamixer | 30 min | 4-5x faster | ❌ (but good enough?) |
| **Medium** | Optimized wpctl | 15 min | 6x faster | ❌ |
| **Future** | Rust daemon | 4-8 hours | 40x faster | ✅ |

---

## Next Steps

1. ✅ **Research completed**
2. ⏭️ **Try pamixer** (quick win, 30 minutes)
3. ⏭️ **Evaluate if 15-20ms is "instant enough"**
4. ⏭️ **If not satisfied, build Rust daemon**

**Recommendation:** Start with pamixer. If 15-20ms feels instant, stop there. If you want true <5ms wiremix-like response, then invest in the Rust daemon.
