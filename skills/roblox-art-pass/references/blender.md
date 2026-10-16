# Blender (default for 3D)

Tools: the **blender MCP** (`mcp-for-blender`): scene/object info, `execute_blender_code`
(Python in Blender), viewport screenshots, and optional Poly Haven / Sketchfab / Hyper3D
integrations. Blender must be open with the sidebar (N) → **MCP for Blender → Start MCP Server**.
If the tools fail to connect, ask the developer to click that, don't retry blindly.

## Workflow per model

1. **New file per asset**, saved as `assets/src/<asset>.blend`. Units: metric, and keep a
   reference cube of a known stud size in a hidden collection (see *Scale*).
2. **Load the sketch as a reference image** when there is one, so you model against it, not from
   memory:
   ```python
   import bpy
   img = bpy.data.images.load(r"<repo>/docs/Art/Sketches/sketch-sword-v1.png")
   ref = bpy.data.objects.new("REF_front", None)
   ref.empty_display_type = 'IMAGE'
   ref.data = img
   ref.empty_display_size = 4.0          # roughly the asset's height
   ref.rotation_euler = (1.5708, 0, 0)   # stand it up facing -Y (front view)
   ref.empty_image_depth = 'BACK'
   bpy.context.scene.collection.objects.link(ref)
   ```
   Add a second one rotated 90° on Z for a side sketch. Put REF objects in a `REF` collection
   and exclude it from export.
3. **Block out the silhouette first** with primitives (cube, cylinder, UV sphere at low segments),
   screenshot front/side/3-4, compare with the sketch, fix proportions. Silhouette is what reads
   at Roblox camera distances; details come after.
4. **Refine in the Style Guide's 3D style**: low-poly → bevels sparingly, flat shading, chunky
   proportions; stylized → smooth shading on organic parts only. Join parts per material.
5. **Color**: prefer a small **palette texture** (e.g. 64×64 PNG of the Style Guide swatches) and
   UV each face island onto its swatch. One texture serves every model, stays consistent, and
   imports cleanly. Use `SurfaceAppearance` PBR maps only if the Style Guide calls for realism.
6. **Clean up before export**: apply transforms (scale = 1, rotation = 0), origin at the base
   center (props stand on the ground), recalculate normals outward, delete loose verts, name
   every mesh (`Sword_Blade`, `Sword_Grip`): names survive import and help the builder.
7. **Check the budget**: triangle count per mesh (see `roblox-import.md`); decimate or simplify
   hidden faces if over.
8. **Preview**: viewport screenshots front / side / 3-4 / top, with the REF image visible for
   the side-by-side and once without. Save PNGs to `docs/Art/Previews/`.
9. **Export** (after approval): FBX or glTF/GLB to `assets/models/<asset>.fbx`, selected
   objects only, REF collection excluded, `apply transforms` on.

## Scale

Roblox works in studs. Decide the mapping once per project, write it in Tools & Setup, and keep it:
model next to a reference cube sized to a known stud size (e.g. a 2×2×2-stud crate, or a 5-stud
tall character block), export it with the first asset, and check in Studio that it measures right.
If it doesn't, fix the export scale in Blender, never by resizing each model in Studio.

## Rigs and animation

- Props and buildings: no rig. Moving parts (a door, a lid) as separate named meshes; the code
  animates them.
- Creatures/pets that bob, hop or wave: separate meshes animated by code (TweenService/CFrame) is
  often enough and simplest.
- Skinned characters: an armature exported with the FBX imports as a rig with Bones; animations
  are then authored in Studio's Animation Editor or imported. Ask before going this route: it's
  the most time-expensive kind of asset.

## Optional generators and libraries

| Source | Good for | Watch out |
|---|---|---|
| Poly Haven | CC0 textures, HDRIs, some models | Realistic style; may clash with stylized games |
| Sketchfab | Specific models | Per-model license (credit needed for CC-BY); log it; often too many triangles |
| Hyper3D (image/text → 3D) | A starting mesh from a sketch | Needs a key, may cost money; messy topology; always clean up and restyle |

Use them only when the developer agrees, and log source + license in the art log.

## Gotchas

- Check each tool result for errors: Python exceptions come back as text, not failures.
- Run viewport screenshots one at a time.
- Large scenes slow every call; keep one asset per file.
