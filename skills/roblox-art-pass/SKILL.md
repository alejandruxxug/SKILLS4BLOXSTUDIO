---
name: roblox-art-pass
description: >
  Turn a Roblox game's art needs into approved, in-game assets: read the mechanic spec and the
  game's Style Guide, collect the developer's sketches and reference images, list every asset
  (3D models, UI screens, icons, textures, sprites, thumbnails), route each one to the right tool
  (Blender through the blender MCP by default for 3D, code-built Studio parts as the fallback,
  Figma for UI and icons, Aseprite for pixel art, Canva/SVG for illustrations), draft it, show
  previews, get the developer's approval, then export, import or upload it to Roblox and wire the
  asset ids into config for the builder. Logs every sketch, reference and verdict in the game's
  docs. Use this whenever a game-mechanic spec is done and needs art, or the user asks to model,
  design, draw, make or "do the art/visuals/models/UI/icons" for their Roblox game, wants a 3D
  model from a sketch, says "here's my drawing, make it 3D", wants a pet/building/prop/weapon
  model, a shop screen, game icons or a thumbnail, even if they don't say "art pass". Not for
  game logic, bug fixing, or sound (roblox-sound-pass).
user-invocable: true
---

# Roblox art pass

A mechanic spec says *what* the game does. This skill makes *what it looks like*, and gets it into
Roblox with asset ids a builder can use. The developer stays the art director: **nothing gets wired
into the game until they've seen it and said yes.**

What makes it work:

1. **The developer's own art is the best input.** A rough sketch beats a paragraph of description.
   Ask for sketches and references first, look at them, log them, and model against them.
2. **One list, routed by tool.** Every asset gets a row and a tool. You load only the tool guides
   the list needs, so a pass that's all UI never reads the Blender guide.
3. **Approved where it's truest.** 3D and in-world art: a Studio screenshot of the asset in the
   game (characters get a Blender design check first). UI: the Figma frame, before it's built,
   because the developer can tweak it there themselves and nothing gets coded twice.

If the project has the agent team (`.claude/agents/art.md`), this skill is the `art` agent's
playbook (Opus). Run it there, or in the main session if there's no team.

## 0. Is it time for art?

Check the **build mode** (CLAUDE.md, the hub, or the spec's override):

- **Mechanic-led (greybox first):** the full art pass runs only on mechanics whose loop the
  developer has approved in a playtest (the Build Plan's 🧪 milestone). Asked earlier? Say so
  plainly ("this mechanic hasn't been playtested yet; if it changes, the models get thrown away")
  and offer the **placeholder kit** instead (below). If they still want art now, it's their call:
  do it and note it in the design log.
- **Visual-led (art first):** start with a **style test**: one representative asset (or one full
  scene) taken all the way to approved, before the rest of the list. It locks the look cheaply.

**The first 3D asset of a game is always a style test, and a real decision point.** Make it in
Blender, show it in Studio next to the placeholders and the character, and ask: "does Blender's
look fit this game, or should its 3D be built from parts?" Write the answer into the Style Guide
(3D style) and the design log. If parts win, route the game's 3D to `studio-parts.md` from then
on: that's a style choice, not a failure.
- Either way, a mechanic whose fun *is* its visuals (an entrance cinematic, a reveal) can be
  flagged art-first in its spec.

### The placeholder kit (greybox)

Placeholders are for judging the loop, so they have to be tidy enough not to bias a playtest:
- right **size and silhouette** (a box the size of the real sword, not a 1-stud cube)
- Style Guide **colors**, one per role (player stuff, enemies, pickups, danger)
- **labels** where shape alone doesn't say what it is (a SurfaceGui text, a simple icon)
- **feel kept in**: sounds, pops, screen shake, number pop-ups. On Roblox much of the fun *is*
  the feel, and it's cheap; leaving it out makes a good loop test badly
- built in code (`references/studio-parts.md`), named like the final asset, so the real model
  later replaces it at the same config key without touching game logic

## 1. Ground yourself

Read, quickly:
- **The spec**: its "Assets needed" section if it has one (game-mechanic writes it), otherwise its
  Screens, Animation & feel and Content sections. Every screen, item, creature and effect is a
  candidate asset.
- **The Style Guide** (`docs/<Game> – Style Guide.md` or wherever CLAUDE.md says): palette, fonts,
  UI shape language, 3D style, the inputs table, the art log. No Style Guide? Make a short one
  first (direction in one line, palette, 3D style, UI shapes) from their references and get a
  quick yes. Every asset after this follows it, so it's worth five minutes.
- **What exists**: `assets/` sources, approved art in the art log, existing UI components and 3D
  models in the place (`search_game_tree`). Reuse before you make.
- **Tools available**: `claude mcp list` (or the tools you have): blender, a Figma MCP (use the
  one CLAUDE.md names), aseprite, roblox-studio, Canva. Missing tool → fall back (see routing)
  and say so.

## 2. Ask for the developer's art

Before drafting anything, offer it plainly:

> "Do you have sketches, reference pictures or a style for any of these? Drop them in
> `docs/Art/Sketches/` (your drawings) or `docs/Art/References/` (screenshots, photos, other
> games), or give me a path. A sketch of the shape, even a rough one on paper photographed with a
> phone, makes the 3D model much closer to what you imagine."

- Images pasted into chat may not exist as files on disk; ask for a file or a path, and copy it
  into the right folder with a clear name (`sketch-<asset>-v1.png`).
- **Look at every image** (Read it). Write down what you see: proportions, silhouette, key
  features, colors, and what's ambiguous (the back of the model, the scale).
- Log each one in the Style Guide's inputs table: file · kind (sketch / reference / style) · for
  which asset · what to take from it · date.
- Unclear sketch → ask one plain question ("is the tail curled up or hanging down?") with
  `AskUserQuestion`, rather than guessing.

No art? Fine. Work from the spec and the Style Guide, and show early.

## 3. The asset list

One table, saved in the spec's folder or the Style Guide (wherever the project keeps it):

| # | Asset | Where it's seen | Kind | Tool | Size / budget | Input | Priority |
|---|---|---|---|---|---|---|---|
| A1 | Sword | hand, shop | 3D model | Blender | ~1.5k tris, 4 studs | sketch-sword-v1.png | v0.1 |
| A2 | Shop screen | night HUD | UI screen | Figma | phone 844×390 | ref-shop.png | v0.1 |
| A3 | Coin icon | HUD, shop | icon | Figma (svg) | 128 px | — | v0.1 |

Show it to the developer (`AskUserQuestion`: "this list right? anything missing or not needed for
v0.1?") before drafting. Cutting assets here is the cheapest cut you'll ever make.

## 4. Route each asset

| Asset kind | Default | Fallback | Guide |
|---|---|---|---|
| 3D models: creatures, pets, props, weapons, buildings, vehicles | **Blender** (blender MCP) | Studio parts built in code | `references/blender.md` |
| Blocky/kit pieces where parts *are* the style, map layout, quick placeholders | Studio parts in code | Blender | `references/studio-parts.md` |
| Textures, materials | Studio MCP `generate_texture` / `generate_material`, or Blender bake | Poly Haven (CC0) via blender MCP | `references/blender.md`, `references/studio-parts.md` |
| UI screens, buttons, panels, icons | **Figma** | SVG written by hand + Python export | `references/figma-ui.md` |
| Pixel art: decals, pixel UI, 2D sprites | **Aseprite** (aseprite MCP) | — | `references/aseprite.md` |
| Game icon, thumbnails, illustrations, logos | Figma or Canva | SVG | `references/illustration.md` |

Read **only** the guides your list needs. Every guide ends in the same place: getting the asset
into Roblox, covered in `references/roblox-import.md` (read it once per pass, before exporting).

Blender is the 3D default because it gives real shapes and silhouettes that parts can't. Parts
stay useful when the game's style *is* blocky, for things a player builds or that change at
runtime, and for quick placeholders while a model waits for approval.

## 5. Draft and preview

For each asset, smallest version first:
- Build it in its tool, following the Style Guide and its input sketch.
- **Look at your own work** before showing anyone (Blender viewport shots next to the sketch, a
  Figma screenshot, a Studio capture). Compare against the sketch/reference and fix what's
  obviously off.

## 6. Approval: Studio screenshots

**For 3D and in-world art, the approval is a Studio screenshot**, because it's the truest view of
the game: the player's camera distance, the game's lighting, next to a character, on a phone.
Renders are working views (the developer's rule). **UI is approved in Figma** before it's built
(below).

### Design check in Blender (characters and self-contained models only)

Characters, pets, creatures and other standalone models (a weapon, a vehicle, a statue) get
designed before they go into the game: proportions, face, silhouette. For these, show Blender
viewport shots (front / side / 3-4, the sketch next to them) and ask "✅ design / tweak / redo"
before importing. It saves importing a model whose design is still moving. Everything else
(environment, props in a scene, buildings in the map, UI, textures, effects) skips this and goes
straight to the Studio check.

### The Studio check (every asset)

Import the asset privately into Studio (nothing is published) or build it there, and show it where
it lives:
- **3D**: in the **Review Room** (below) at real scale next to an R15 dummy, *and* at its real spot
  in the map if it has one. `screen_capture` from the player's camera distance, not close-ups:
  front, 3/4, and from far away (the silhouette at distance is what players see).
- **UI**: approved **in Figma first** (see *UI is Figma-first* below); the Studio capture of the
  built screen (fake data via a `DebugService` command like `ShowScreen("Shop")`, phone-size
  viewport) is then a match check against the approved frame, not a second design review.
- **Effects, textures, lighting**: captured in the scene they belong to.

Put the captures on the **game's Figma board** (below), and write a short **review note**
`docs/Art/Reviews/R<nnn> – <batch>.md` (previews saved in `docs/Art/Previews/`, embedded with
`![[...]]`, one line per asset on what you're unsure about, a link to the board section). Then ask
**for the whole batch at once**, not asset by asset: one `AskUserQuestion` round with a multi-select
"which of these are ✅?", then a tweak/redo question only for the ones left. And offer: "or press Play and run
`Net.Debug:InvokeServer("ReviewRoom")` to walk around it yourself". Walking around catches what
screenshots hide (scale, camera clipping, how it feels to stand next to it).

### UI is Figma-first

UI is the exception to "approve in Studio": Figma is far faster to design in, and the developer
can edit a frame themselves (move a button, change a color, rewrite a label) before anything is
built, so nothing gets coded twice.
1. Design the screen in Figma (reusing the file's components, styles and icons).
2. The developer approves the frame, or edits it directly and says it's done.
3. **Re-read the frame right before building** (the Figma MCP's design context): the developer may
   have changed it since you last looked. Build from what's there now, never from your own earlier
   version.
4. Build it, capture it in Studio on a phone viewport, put that capture next to the frame on the
   board. It should match; differences are build bugs, not new design questions.

### The Figma board

The game's Figma file is its visual board: everything visual lands there, so the developer sees
the whole game's look in one place and the history of every asset. Use the file and the Figma MCP
named in CLAUDE.md / Tools & Setup (no Figma MCP → the review note alone).

| Page | What lands there |
|---|---|
| 🖼️ Inputs | The developer's sketches and references (import the images from `docs/Art/`), grouped by asset, each labelled with its file name |
| 🎨 Style | Palette, fonts, UI shapes, the approved style test |
| 🧪 Reviews | One **section per review** (`R003 – Pets`): per asset a row, left to right: sketch → Blender design shots (characters) → Studio screenshots → a verdict label (✅ / tweak / redo + date). Tweaks add a new row underneath, so the iterations stay visible |
| ✅ Approved | The final Studio screenshot of every approved asset, with its asset id: the game's living art catalog |
| 📱 Screens / 🧩 Components / 🎨 Icons | UI design work, as usual |

Import screenshots as images (e.g. Figwright `import_image`), keep them at the captured size, and
label every image (asset id, view, date). Create missing pages the first time; never rearrange or
delete the developer's own frames.

While the batch waits for the developer, don't idle: start the next assets, or anything that
doesn't depend on these (with the agent team, the orchestrator puts the review in the Build Plan's
⏳ Waiting on you table).

Log each verdict in the art log (date · asset · from sketch/ref · tool · verdict · asset id) and in
the review note, and update the verdict label on the board (and copy the approved shot to ✅ Approved).
Iterate or park with a note.

**Nothing goes into config or game code before the Studio screenshot is approved.** Importing for
review is fine; wiring an unapproved asset into the game is the expensive rework this prevents.

### The Review Room

A small stage built from code (not by hand, so it survives Rojo and can be rebuilt), far from the
map or under it, that exists **only in Studio** (`RunService:IsStudio()`): a neutral floor with a
stud grid, an R15 dummy for scale, the game's lighting, a pedestal per asset with a label (asset
id from the list), and a `DebugService` command `ReviewRoom` that teleports the player there. The
builder adds it once per project (a short builder module + the command); after that, putting an
asset up for review is one line. In the Build Plan's 🧪 milestones it doubles as a place to show
friends the art in progress.

## 7. Export, import, wire

Per `references/roblox-import.md`:
- Export from the tool into `assets/` (sources in `assets/src/`, exports in `assets/models/` or
  `assets/ui/`).
- Get it into Roblox: Studio MCP `upload_image` for images, the 3D Importer or the Open Cloud
  Assets API for meshes, code for parts.
- Put every asset id in a config module (e.g. `Shared/Config/Assets`), never hardcoded in logic.
- Check it in Studio: scale against a character, colors under the game's lighting, on a phone-size
  viewport for UI.

## 8. Hand off

- Art log rows filled with asset ids; asset list updated (✅ / parked).
- For the builder: a short note per asset (what it is, config key, where it goes, animation or
  interaction notes). With the agent team, this becomes part of the next batch brief.
- Tell the developer: what's approved and in, what's parked and why, what only they can do
  (3D Importer clicks, an Open Cloud key, publishing).

## Being honest

- If a sketch is beyond the tools (a highly detailed realistic character), say so and propose the
  closest achievable version (stylized, fewer details) rather than shipping something worse.
- Third-party assets (Sketchfab, Poly Haven, AI generators like Hyper3D) come with licenses and
  terms: log the source and license in the art log, prefer CC0, and tell the developer when an
  asset needs credit or might be paid.
- Generated or downloaded meshes still need to fit the Style Guide; a mismatched model breaks the
  look more than a missing one.
