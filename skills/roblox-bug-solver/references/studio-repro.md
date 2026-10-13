# Reproducing Roblox bugs in Studio

Recipes for step 3. The Studio MCP tools are `mcp__roblox-studio__*`. Every call needs a
`studio_id` from `list_roblox_studios`; pick the instance by its place name.

## Before you start

- **State**: `get_studio_state` → Edit or Play, and which datamodels exist (Edit / Server / Client).
- **Someone else's Play**: if Play is running and you didn't start it, ask before stopping it or
  starting a new one. Also check how long it's been running (`workspace.DistributedGameTime` on
  the Server): an old Play may be running old code.
- **Code reaches Studio**: with Rojo, edits only arrive while the plugin is connected. Compare a
  line of the file with `game:GetService(...).Path.To.Script.Source` in the **Edit** datamodel. If
  they differ, ask the developer to reconnect Rojo. Don't edit scripts inside Studio: Rojo
  overwrites them.
- **Console**: `get_console_output` before and after. Clear signals: `warn` lines, errors with
  stack traces, the game's own `print` tags.

## Driving the game

- **Prefer the game's own doors**: admin commands, `RemoteFunction`s / `RemoteEvent`s fired from
  the Client datamodel (`Net.X:InvokeServer(...)`), attributes the game already reads. They run
  the real code path.
- **`require` from `execute_luau` gives a fresh, uninitialized copy** of a module (not the
  running service), so calling service methods that way tests nothing. Go through remotes, or read
  state the service publishes (attributes, values, folders).
- **Time**: look for test configs (`FAST_TEST`, shorter phases in Studio) or admin skips (jump to
  the next phase, end the round). Note in the evidence when a timer was skipped.
- **Input**: clicks through MCP coordinates often miss scaled UI. Prefer firing the button's
  remote, or find the button by path and read its `AbsolutePosition`. `ProximityPrompt`s only show
  on screen: point the camera at them, or call `InputHoldBegin/End` on the prompt.
- **Studio-only test flags** (e.g. "restart the tutorial on every Play") can hide or fake a bug.
  Read the config before trusting what you see, and say which flags were on.

## Bugs that need saved data or a rejoin

"It happens again when I come back", "my progress reset", "it only counts sometimes".

- **Is saving on?** If the game uses DataStores, Studio needs *Game Settings → Security → Enable
  Studio Access to API Services*. Look for a "no DataStore access" or "unavailable" warning in the
  console. Without it every Play starts with fresh data, which is itself a common "came back and
  it reset" report that isn't a code bug.
- **Rejoin = stop Play, start Play.** Each Play is a new server: new `JobId` (`""` in Studio!), new
  in-memory tables, round counters back to 1. Saved data survives only if it was saved before
  `PlayerRemoving` / `BindToClose` finished.
- **Read the saved value directly** to separate "not saved" from "saved but not loaded": from the
  Server datamodel, `DataStoreService:GetDataStore(name):GetAsync(key)` (read-only, never write
  to a real player's key). Compare with the in-game attribute after the rejoin.
- **Leaving mid-way** is a different path from staying until the end: test both. Many "counts at
  the end of the round" bugs only show when the player leaves early.

## Server vs client

- Read the same thing in both datamodels. The server owns the truth. The client may have a stale
  or locally-computed copy. Disagreement = a replication or ownership bug.
- Attributes set by the server replicate to the client. Values set by the client don't go back.
- Things that don't replicate: server-only tables, `ServerStorage`, anything in a server
  `ModuleScript`'s locals.
- `StreamingEnabled`: far-away parts may not exist on the client yet. A client script that
  `FindFirstChild`s them once at startup misses them. Use `WaitForChild` / `ChildAdded`, or
  `ModelStreamingMode = Persistent`.

## Timing and ordering

- Two handlers on the same event run in no guaranteed order across services. If one resets state
  that the other reads, that's a race.
- "First join" vs "joined mid-round" vs "joined during the end screen" are three paths. Test the
  one the symptom names.
- Something that works once and breaks the second time: look for state that is only reset in one
  place (a new round, but not a rejoin) or connections that are made twice.

## When Studio can't reproduce it

Some bugs need real conditions: two live servers (session locks, cross-server messaging), real
DataStore throttling or outages, real Robux receipts, mobile-only input, many players. Say so,
then:

- Trace the path line by line and write it as player steps.
- Propose a cheap confirmation: a `warn` with the key values on that path, checked on a published
  test server, or a Team Test with a second account.
- Mark the cause as **likely, not reproduced** in the explanation.

## Clean up

Remove temporary prints, reset admin overrides you changed (like a forced player day or test
money), and leave Studio in the state you found it (stop Play only if you started it).
