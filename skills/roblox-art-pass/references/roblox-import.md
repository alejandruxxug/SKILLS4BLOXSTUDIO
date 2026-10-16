# Getting assets into Roblox

Read once per pass, before exporting. Import privately for the Studio check (after the Blender design check for characters); config and game code only after the Studio screenshot is approved.

## Limits to design for

| Thing | Limit / guideline |
|---|---|
| Mesh triangles | Up to 20,000 triangles per mesh. Aim far lower for props (hundreds to a few thousand) because phones render them |
| Textures / images | Displayed at up to 1024×1024; bigger uploads are downscaled |
| Materials per mesh | Each material imports as its own MeshPart; fewer materials = fewer parts |
| Formats (3D Importer) | `.fbx`, `.obj`, `.gltf` / `.glb` |
| Moderation | Every upload is reviewed; an asset can be rejected or take a while to appear |

## Images (UI, icons, decals, textures)

- Studio MCP `upload_image` (or `store_image`) returns an asset id; or the developer uploads
  through the Creator Dashboard / Asset Manager.
- Put the id in config: `Shared/Config/Assets` (or the project's Icons/Theme module) as
  `"rbxassetid://<id>"`.

## Meshes (from Blender)

Two routes; pick with the developer once and write it in Tools & Setup:

1. **3D Importer (manual, simplest)**: Studio → File/Home → **Import 3D** → pick the `.fbx`/`.glb`
   → check the preview (scale, orientation, materials) → Import. Then the agent moves the result
   into `ReplicatedStorage`/`ServerStorage` (e.g. `Assets/Models/<Name>`) or the place, renames
   it, and sets `CollisionFidelity` (Box/Hull for props) and `RenderFidelity`. The developer
   clicks the import; ask them, then verify it arrived with `search_game_tree`.
2. **Open Cloud Assets API (automated)**: the developer creates an API key with Assets
   read/write for their account or group; a script uploads the file as a Model and returns an id;
   the Studio MCP inserts it (`insert_asset`). Worth it when there are many models. Never print or
   commit the key: read it from an environment variable.

**Rojo note:** imported meshes live in the place file, not in `src/`. Keep the exported files in
`assets/models/` as the source of truth, store imported models somewhere predictable, and remind
the developer to **save/publish the place** after importing.

## Parts-built models

No upload. The builder module is the asset; config holds its parameters (colors, sizes).

## After wiring: check in Studio

- Scale next to a character; colors under the game's real lighting.
- UI on a phone-size viewport; text readable.
- Console clean; no "failed to load asset" warnings (wrong id, still in moderation, or not owned
  by the game's creator).

## Log it

Art log row: date · asset · from sketch/ref · tool · ✅ · asset id (or builder module path).
