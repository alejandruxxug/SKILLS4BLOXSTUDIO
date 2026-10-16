# Studio parts built in code (fallback for 3D, default for blocky kits)

When parts are the right call: the game's style *is* blocky (classic Roblox, Pet Simulator
cubes), things that change at runtime (build modes, upgrades that add pieces), the map's layout,
and quick placeholders while a Blender model waits for approval. No upload, no moderation, fully
editable from code.

## How

- **A builder module per model** in the repo (e.g. `src/client/World/Models/<Name>.luau` or
  `src/server/World/<Name>Builder.luau`), never hand-built in Studio: Rojo can't save Studio
  edits, and a builder function can make variants (colors, sizes, tiers) from parameters.
- Shape: `Part` (Block, Cylinder, Ball, Wedge, CornerWedge), `WedgePart`, unions avoided (slow,
  fragile). Group in a `Model` with a `PrimaryPart` at the base; weld everything to it
  (`WeldConstraint`) and anchor only the root, so the whole model moves as one.
- Look: Style Guide palette as `Color3.fromHex`, `Material` (SmoothPlastic for clean, Plastic
  for studs), a `Highlight` for silhouette outlines if the style uses them.
- Performance: `CanCollide = false` / `CanQuery = false` / `CanTouch = false` on decoration;
  `CastShadow = false` on tiny pieces; keep part counts per model modest (tens, not hundreds).
- Streaming: if the place has `StreamingEnabled`, models far from spawn need
  `ModelStreamingMode = Persistent` or they won't exist on the client.

## Studio MCP generators

`generate_mesh`, `generate_procedural_model`, `generate_material`, `generate_texture` make
assets inside Studio from a text prompt. Good for fillers (rocks, bushes, crates, materials) and
textures. They don't follow a sketch closely: for anything the developer drew, use Blender.

## Preview

Build it on a **preview stage** away from the map (a flat baseplate with a neutral background and
a character-size block for scale), point a Scriptable camera at it, `screen_capture` front / side
/ 3-4. Move or delete the stage after. Screenshots one at a time.
