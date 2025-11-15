# Rust Volume Control Daemon - Design Document

## Problem Statement

Current volume control implementation has ~88ms latency because:
1. Scripts read from filesystem cache (I/O)
2. Call `wpctl` subprocess (fork/exec)
3. Parse wpctl output (string processing)
4. Cache update scans all streams with multiple subprocess calls

**Target**: <5ms instant response like wiremix

## Solution: Rust Daemon

A lightweight Rust daemon that:
- Connects directly to PipeWire
- Maintains in-memory app -> stream mapping
- Listens to PipeWire events
- Exposes Unix socket IPC for volume control
- Updates waybar via signals

### Architecture

```
┌─────────────────┐
│   Hyprland      │
│   Keybinds      │
└────────┬────────┘
         │ Unix socket message
         ▼
┌─────────────────┐      PipeWire API
│  Rust Daemon    │◄────────────────────┐
│  (always-on)    │                      │
└────────┬────────┘                      │
         │                               │
         ├─► In-memory cache             │
         │   app -> stream IDs           │
         │                               │
         ├─► Signal waybar (RTMIN+8)     │
         │                               │
         └─► Control PipeWire ───────────┘
                 (direct API, no subprocess)
```

### Performance Comparison

| Operation | Current (Bash) | Rust Daemon |
|-----------|----------------|-------------|
| Volume change | 88ms | <5ms |
| Cache update | 500-1000ms | Real-time |
| Memory usage | Multiple processes | Single daemon ~5MB |
| CPU usage | Spike on each key | Idle most of time |

## Implementation Plan

### Phase 1: Core Daemon

**File**: `~/.config/nixos/rust/audio-daemon/src/main.rs`

**Dependencies**:
```toml
[dependencies]
pipewire = "0.8"
tokio = { version = "1", features = ["full"] }
serde = { version = "1", features = ["derive"] }
serde_json = "1"
```

**Key Components**:

1. **PipeWire Connection**
   - Connect to PipeWire using pipewire-rs
   - Subscribe to node events (add/remove/change)
   - Direct API calls for volume/mute

2. **Stream Tracker**
   ```rust
   struct StreamTracker {
       vesktop: Vec<u32>,    // Stream IDs
       youtube: Vec<u32>,
       twitch: Vec<u32>,
       music: Vec<u32>,
   }
   ```

3. **IPC Server** (Unix socket)
   ```rust
   enum Command {
       VolumeUp { app: String, amount: f32 },
       VolumeDown { app: String, amount: f32 },
       Mute { app: String },
       GetVolume { app: String },
   }
   ```

4. **Event Loop**
   - Listen to PipeWire events
   - Update stream tracker on changes
   - Handle IPC commands
   - Signal waybar on changes

### Phase 2: Client Scripts

**File**: `~/.config/nixos/scripts/vesktop-volume-fast`

```bash
#!/usr/bin/env bash
# Fast volume control using Rust daemon

ACTION="$1"
echo "{\"app\":\"vesktop\",\"action\":\"$ACTION\"}" | \
    socat - UNIX-CONNECT:/run/user/$UID/audio-daemon.sock
```

Response time: <5ms (no filesystem, no subprocess, just socket write)

### Phase 3: Systemd Service

**File**: `~/.config/nixos/modules/audio-daemon.nix`

```nix
{ config, pkgs, ... }:

{
  # Build the Rust daemon
  environment.systemPackages = [
    (pkgs.rustPlatform.buildRustPackage {
      pname = "audio-daemon";
      version = "0.1.0";
      src = ../rust/audio-daemon;
      cargoLock = {
        lockFile = ../rust/audio-daemon/Cargo.lock;
      };
    })
  ];

  # Systemd user service
  systemd.user.services.audio-daemon = {
    description = "Fast Audio Control Daemon";
    wantedBy = [ "default.target" ];
    after = [ "pipewire.service" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.audio-daemon}/bin/audio-daemon";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
}
```

## Benefits

### Performance
- **Instant response**: <5ms instead of 88ms
- **No I/O**: Everything in memory
- **No subprocess calls**: Direct PipeWire API
- **Event-driven**: No polling, instant updates

### Reliability
- **No race conditions**: Single daemon manages all state
- **Atomic operations**: Volume changes are immediate
- **Error handling**: Rust's type system prevents common bugs
- **Resource efficient**: One process instead of many scripts

### Features
- **Real-time updates**: Catch external mixer changes instantly
- **Multiple streams**: Handle apps with multiple audio streams
- **Volume limits**: Enforce max volume in daemon
- **Smooth ramping**: Gradual volume changes (optional)

## Code Structure

```
~/.config/nixos/rust/audio-daemon/
├── Cargo.toml
├── Cargo.lock
├── src/
│   ├── main.rs           # Entry point, event loop
│   ├── pipewire.rs       # PipeWire connection & control
│   ├── tracker.rs        # Stream tracking logic
│   ├── ipc.rs            # Unix socket server
│   └── apps.rs           # App detection (vesktop, youtube, etc.)
```

## Migration Path

### Step 1: Build daemon alongside existing scripts
- Both systems run in parallel
- Test daemon thoroughly
- Keep bash scripts as fallback

### Step 2: Switch keybinds to daemon
```nix
# In hyprland.conf
bindel = SUPER,XF86AudioRaiseVolume, exec, echo '{"app":"vesktop","action":"up"}' | socat - UNIX-CONNECT:/run/user/$UID/audio-daemon.sock
```

### Step 3: Remove old bash scripts
- Keep monitor scripts for waybar display
- Remove slow volume control scripts

## Alternative: Smaller Scope

If full daemon is too complex, we could:

1. **Optimize bash scripts**
   - Rewrite app-volume-monitor-multi in Rust
   - Keep volume scripts in bash
   - Would improve cache update speed

2. **Use existing tools**
   - Investigate if pavucontrol/pulsemixer have APIs
   - Check if wiremix can be scripted
   - Look for existing Rust audio daemons

## Estimated Effort

- **Full Rust daemon**: ~8-16 hours development + testing
- **Optimize monitor only**: ~4 hours
- **Research alternatives**: ~2 hours

## Next Steps

1. ✅ **Current improvements committed** (88ms, no notifications)
2. **Research existing solutions** (wiremix source, pavucontrol APIs)
3. **Prototype simple Rust daemon** (just vesktop, no IPC)
4. **Benchmark** (compare to wiremix performance)
5. **Decide**: Full daemon vs optimized scripts
6. **Implement chosen solution**

## Resources

- [pipewire-rs crate](https://crates.io/crates/pipewire)
- [PipeWire API docs](https://docs.pipewire.org/)
- [Tokio async runtime](https://tokio.rs/)
- [Wiremix source code](https://github.com/aryak93/wiremix) (for reference)

---

**Status**: Design phase - awaiting decision on implementation approach
