# Day-0 checklist: connect Studio and prove it

Each item here cost a real project an afternoon in its first week. Check them once now.

## 1. Rojo is really connected

- `rojo serve` (background). The developer opens the place and clicks **Plugins → Rojo → Connect**.
  If the plugin isn't installed: `rojo plugin install`, then restart Studio.
- **Verify, don't assume:** read `ServerScriptService.Server.Main` (`script_read` or
  `search_game_tree`) in the Edit datamodel. Missing → not connected (wrong port, plugin not
  clicked, another project served).
- Tell the developer: **after reopening the place, Rojo must be reconnected**, or file edits
  silently never reach Studio. This goes in Tools & Setup and CLAUDE.md.

## 2. Studio settings to check (report; let the developer change them)

| Check | How | Why it matters |
|---|---|---|
| Place published? | `game.PlaceId ~= 0` via `execute_luau` | DataStores and API access need a published place |
| Studio API access | Game Settings → Security → Enable Studio Access to API Services | Off = DataStore calls fail in Studio and saves look broken. **On = Studio writes to the real DataStores**: the save service must use `GameConfig.DATA_SCOPE` |
| StreamingEnabled | `workspace.StreamingEnabled` | On by default in new places: far-away parts don't exist on the client, so code that finds them fails. Big builds need `ModelStreamingMode = Persistent` or a decision to turn streaming off |
| HTTP requests | Game Settings → Security | Only if they'll call external APIs |
| Avatar type | R15/R6 in Game Settings → Avatar | Animations and rigs depend on it |

## 3. Smoke Play

1. `start_stop_play` (start).
2. `get_console_output`. Pass = all three, no red errors:
   - `[init] server ready`
   - `[init] client ready`
   - `[init] ping ok (<n> ms)`
3. Try the backdoor from the client context: `Net.Debug:InvokeServer("List")` → `true, {"Dump", "List"}`, and `Net.Debug:InvokeServer("Dump")` → `true, {}` (no state registered yet).
4. `screen_capture` once for the progress log, then stop Play.

| Symptom | Likely cause |
|---|---|
| No prints at all | Rojo not connected, or Main files lost their `.server` / `.client` suffix |
| Server prints, client doesn't | `src/client` not under `StarterPlayerScripts` in `default.project.json` |
| `ping FAILED` / infinite yield on `Net` | Net folder name mismatch, or PingService errored in Start (read the error above it) |
| Prints twice | The same scripts exist in the place *and* come from Rojo; delete the Studio copies |

## 4. Gotchas to write into CLAUDE.md now

- Edit files, never scripts in Studio (Rojo overwrites them).
- Hand-built things (lighting, terrain, a map built by hand) live in the place file: **Ctrl+S**.
- `require` inside `execute_luau` returns a fresh, uninitialized module: test through remotes.
- Ask before starting or stopping Play; the developer may be playing.
- Run `stylua` from the repo root.

## 5. Optional tools (check, don't install without a yes)

| Tool | Check | Used by |
|---|---|---|
| Blender + blender MCP | `blender` server in `claude mcp list`; Blender sidebar → MCP for Blender → Start MCP Server | roblox-art-pass (3D, default) |
| Figma MCP | listed in `claude mcp list` | roblox-art-pass (UI, icons) |
| Aseprite MCP | listed | roblox-art-pass (pixel art) |
| `gh` | `gh auth status` | creating the remote |
