# {{GAME_NAME}}

A Roblox game. Design notes live in [`docs/`](docs/) (start with `docs/{{GAME_NAME}}.md`).

## Setup

```bash
rojo plugin install    # once: installs the Rojo plugin into Roblox Studio
rojo serve             # syncs src/ into Studio
```

In Studio: **Plugins → Rojo → Connect**. Edits to `src/` now appear in Studio instantly.

## Structure

| Folder | Lives in Studio at | What goes here |
|---|---|---|
| `src/shared` | `ReplicatedStorage.Shared` | Config, `Net` (remotes), pure classes, utilities |
| `src/server` | `ServerScriptService.Server` | `Main` bootstrap, Services (one per system), server-only classes |
| `src/client` | `StarterPlayerScripts.Client` | `Main` bootstrap, Controllers, UI |

- **Server is the authority:** clients only send requests; the server validates them.
- **Services / Controllers** have `:Init(registry)` (wire dependencies) then `:Start()` (run).
- **Every tunable number** lives in `src/shared/Config`.
- Suffixes: `.server.luau` = Script, `.client.luau` = LocalScript, `.luau` = ModuleScript.
- Format with `stylua src` from the repo root before committing.
